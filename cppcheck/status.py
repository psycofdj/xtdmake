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
l_tests   = l_tree.findall("./error")

if l_result.output_file == "-":
  l_out = sys.stdout
else:
  l_out = open(l_result.output_file, "w")

l_status  = "failure"
l_label   = "%d" % len(l_tests)
if len(l_tests) == 0:
  l_status = "success"
  
l_out.write(json.dumps({ "status" : l_status, "label"  : l_label }, indent=2))
