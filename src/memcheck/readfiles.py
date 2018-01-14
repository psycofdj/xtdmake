#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
import sys
import xml.etree.ElementTree as ET

l_stackinfo = [ "ip", "obj", "fn", "dir", "line", "file"]

def is_empty(p_stack):
  l_res = True
  for c_key in [ "fn", "dir", "line", "file"]:
    l_res = l_res and ("" == p_stack[c_key])
  return l_res

def get_default(p_tree, p_path, p_default=""):
  l_item = p_tree.findall(p_path)
  if len(l_item):
      return l_item[0].text
  return p_default

def process_file(p_path, p_data):
  try:
    l_tree = ET.parse(p_path)
  except Exception as l_error:
    print("error while readfile file '%s'" % p_path)
    os.remove(p_path)
    return

  l_root = l_tree.getroot()
  l_test = {
    "args" : {
      "bin"  : l_root.findall("./args/argv/exe")[0].text,
      "args" : [ x.text for x in l_root.findall("./args/argv/arg") ]
    },
    "errors" : []
  }

  for c_error in l_root.findall("./error"):
    l_what  = c_error.findall("./what")
    if not len(l_what):
      l_what = c_error.findall("./xwhat/text")
    l_kind  = get_default(c_error, "./kind")
    l_count = p_data["stats"].get(l_kind, 0)
    p_data["stats"][l_kind] = l_count + 1
    l_error = {
      "kind"  : l_kind,
      "descr" : l_what[0].text,
      "stack" : [ ]
    }
    for c_stack in c_error.findall("./stack/frame"):
      l_stack = { x : get_default(c_stack, x) for x in l_stackinfo }
      if not is_empty(l_stack):
        l_error["stack"].append(l_stack)
    l_test["errors"].append(l_error)
  p_data["tests"].append(l_test)

def write_xml(p_data):
  sys.stdout.write(json.dumps(p_data))

def main():
  l_data = { "tests" : [], "stats" : {} }
  for c_file in sys.argv[1:]:
    process_file(c_file, l_data)
  write_xml(l_data)
  for c_test in l_data["tests"]:
    if len(c_test["errors"]) != 0:
      sys.exit(1)
  sys.exit(0)

if __name__ == "__main__":
  main()
