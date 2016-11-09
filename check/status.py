#!/usr/bin/python

import sys
import os
import json
import argparse
import xml.etree.ElementTree as ET

l_parser = argparse.ArgumentParser()
l_parser.add_argument("--input-file",   action="store", help ="path to xml check results", required=True)
l_parser.add_argument("--output-file",  action="store", help ="destination output file",   required=True)
l_result = l_parser.parse_args()

l_tree    = ET.parse(l_result.input_file)
l_tests   = l_tree.findall("./Testing/Test")
l_ok      = [ x for x in l_tests if x.get("Status") == "passed" ]

if l_result.output_file == "-":
  l_out = sys.stdout
else:
  l_out     = open(l_result.output_file, "w")

l_status  = "failure"
l_label   = "%d / %d" % (len(l_ok), len(l_tests))
if len(l_tests) == len(l_ok):
  l_status = "success"
if len(l_tests) == 0:
  l_status = "warning"
  
l_out.write(json.dumps({
  "status" : l_status,
  "label"  : l_label,
  "graphs" : [
    {
      "name" : "unittests",
      "series" : [ "failures", "success"  ]
    }
  ],
  "data" : {
    "failures" : len(l_tests) - len(l_ok),
    "success"  : len(l_ok),
  }
}, indent=2))
