#!/usr/bin/python

import sys
import glob
import os
import json
import argparse

l_parser = argparse.ArgumentParser()
l_parser.add_argument("--report-dir",   action="store", help ="path to reports root directory", required=True)
l_parser.add_argument("--output-file",  action="store", help ="destination output file",        required=True)
l_result = l_parser.parse_args()

l_dirs      = glob.glob(l_result.report_dir + "/*/")
l_dirs      = [x for x in l_dirs if not "bower_components" in x]
l_targets   = []
for c_dir in l_dirs:
  l_childs = []
  l_module = os.path.basename(os.path.dirname(c_dir))
  l_items = [
    { "name" : "doc",          "path" : "html/index.html"                         },
    { "name" : "doc-coverage", "path" : "index.html",    "status" : "status.json" },
    { "name" : "cloc",         "path" : "cloc.html",     "status" : "status.json" },
    { "name" : "cppcheck",     "path" : "cppcheck.html", "status" : "status.json" },
    { "name" : "check",        "path" : "index.html",    "status" : "status.json" },
    { "name" : "coverage",     "path" : "index.html",    "status" : "status.json" },
    { "name" : "memcheck",     "path" : "index.html",    "status" : "status.json" },
  ]

  for c_item in l_items:
    l_childData = {}
    l_abspath   = "%s/%s/%s" % (c_dir,    c_item["name"], c_item["path"])
    l_relpath   = "%s/%s/%s" % (l_module, c_item["name"], c_item["path"])
    l_name      = c_item["name"]
    
    if "status" in c_item:
      l_path = "%s/%s/%s" % (c_dir,    c_item["name"], c_item["status"])
      if os.path.exists(l_path):
        l_dfile = open(l_path, "r")
        l_content = l_dfile.read()
        l_status = json.loads(l_content)
        l_childData = l_status   
    if os.path.exists(l_abspath):
      l_childData["name"] = l_name
      l_childData["file"] = l_relpath
      l_childs.append(l_childData)

  l_targets.append({"name" : l_module, "childs" : l_childs })


with open(l_result.output_file, "w") as l_file:
  l_data = json.dumps(l_targets)
  l_file.write("var g_data = %s" % l_data)
