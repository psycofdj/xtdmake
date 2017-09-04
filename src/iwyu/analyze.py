#!/usr/bin/python

import sys
import os
import json
import argparse
import xml.etree.ElementTree as ET
import Queue
import threading
import subprocess
import fnmatch
import time

class Worker(threading.Thread):
  def __init__(self, p_queue, p_app):
    threading.Thread.__init__(self)
    self.m_queue  = p_queue
    self.m_app    = p_app
    self.m_result = {}

  def analyze(self, p_data):
    l_fullTok  = "The full include-list for "
    l_addTok   = " should add these lines:"
    l_rmTok    = " should remove these lines:"
    l_okTok    = " has correct #includes/fwd-decls"
    l_lines    = p_data.split("\n")
    l_file     = None
    l_res      = {}

    for c_line in l_lines:
      if c_line.startswith(l_fullTok):
        l_newFile = c_line.replace(l_fullTok, "")[:-1]
        if l_newFile != l_file:
          l_file = l_newFile
          l_res[l_file] = { "full" : [], "errors" : False, "add" : [], "rm" : [] }
        l_dst = l_res[l_file]["full"]
        continue

      if c_line.endswith(l_addTok):
        l_newFile = c_line.replace(l_addTok, "")
        if l_newFile != l_file:
          l_file = l_newFile
          l_res[l_file] = { "full" : [], "errors" : False, "add" : [], "rm" : [] }
        l_dst = l_res[l_file]["add"]
        continue

      if c_line.endswith(l_rmTok):
        l_newFile = c_line.replace(l_rmTok, "")
        if l_newFile != l_file:
          l_file = l_newFile
          l_res[l_file] = { "full" : [], "errors" : False, "add" : [], "rm" : [] }
        l_dst = l_res[l_file]["rm"]
        continue

      if l_okTok in c_line:
        l_newFile = c_line.replace(l_okTok, "")[1:-1]
        if l_newFile != l_file:
          l_file = l_newFile
          l_res[l_file] = { "full" : [], "errors" : False, "add" : [], "rm" : [] }
        continue

      if (c_line == "---") or (0 == len(c_line)):
        continue

      l_dst.append(c_line)

    for c_file, c_data in l_res.items():
      l_rm = []
      for c_rm in c_data["rm"]:
        l_rm.append(c_rm[2:])
      c_data["rm"] = l_rm
    return l_res


  def processItem(self, p_item):
    l_file = p_item["file"]
    l_cmd  = p_item["command"]
    l_args = [ self.m_app.iwyu_bin ]
    l_args += l_cmd.split("-o")[0].split(" ")[1:]
    l_args += self.m_app.iwyu_args.split(" ")
    l_args += [ l_file ]
    l_args = filter(lambda x:len(x) > 0, l_args)
    if self.m_app.verbose:
      print("  -> running : %s" % " ".join(l_args))
    l_proc = subprocess.Popen(l_args, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    l_proc.wait()
    l_content = l_proc.stderr.read()
    if self.m_app.verbose:
      print("  -> result for %s : " % l_file)
      print(l_content)
    l_code = l_proc.returncode
    if l_code == -6:
      return { l_file : { "full" : [], "errors" : l_content, "add" : [], "rm" : [] } }
    return self.analyze(l_content)

  def run(self):
    while True:
      try:
        l_item = self.m_queue.get(block=False)
        sys.stdout.write("processing %s (%d left)\n" % (l_item["file"], self.m_queue.qsize()))
        l_data = self.processItem(l_item)
        self.m_result.update(l_data)
      except Queue.Empty:
        break

class App:
  def __init__(self):
    l_parser = argparse.ArgumentParser()
    l_parser.add_argument("--build-dir",    action="store",      help ="current module build directory",              required=True)
    l_parser.add_argument("--output-file",  action="store",      help ="output result to given file, '-' for stdout", required=False, default="-")
    l_parser.add_argument("--commands",     action="store",      help ="path to compile commands file",               required=True)
    l_parser.add_argument("--iwyu-bin",     action="store",      help ="include-what-you-use bin path",               required=False, default="include-what-you-use")
    l_parser.add_argument("--exclude",      action="store",      help ="exclude given file pattern from list",        required=False, default="")
    l_parser.add_argument("--jobs",         action="store",      help ="number of parallel jobs",                     required=False, default=4)
    l_parser.add_argument("--verbose",      action="store_true", help ="verbose output",                              required=False, default=False)
    l_res, l_remains = l_parser.parse_known_args(namespace=self)
    self.iwyu_args = " ".join(l_remains)

  def getItemsToProcess(self):
    l_file    = open(self.commands, "r")
    l_content = l_file.read()
    l_list    = json.loads(l_content)
    l_res     = []
    for c_item in l_list:
      l_dir  = c_item["directory"]
      l_file = c_item["file"]
      if l_dir.startswith(self.build_dir):
        if not fnmatch.fnmatch(l_file, self.exclude):
          l_res.append(c_item)
    return l_res

  def run(self):
    l_threads = []
    l_result  = {}
    l_queue   = Queue.Queue()
    l_items   = self.getItemsToProcess()

    [ l_queue.put(x) for x in l_items ]
    [ l_threads.append(Worker(l_queue, self)) for x in range(int(self.jobs)) ]

    for c_thread in l_threads:
      c_thread.daemon = True

    [ x.start() for x in l_threads ]

    while True:
      l_alive = False
      for c_thread in l_threads:
        c_thread.join(1)
        l_alive = l_alive or c_thread.isAlive()
      if not l_alive:
        break

    [ l_result.update(x.m_result) for x in l_threads ]

    self.outputResult(l_result)
    return 0

  def outputResult(self, p_data):
    l_file = sys.stdout
    if self.output_file != "-":
      l_file = open(self.output_file, "w")
    l_content = json.dumps(p_data, indent=2)
    l_file.write(l_content)


l_app = App()
sys.exit(l_app.run())

# Local Variables:
# ispell-local-dictionary: "american"
# End:
