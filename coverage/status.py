#!/usr/bin/python

import sys
import os
import json
import argparse
import xml.etree.ElementTree as ET

l_parser = argparse.ArgumentParser()
l_parser.add_argument("--input-file",   action="store", help ="path to xml results",            required=True)
l_parser.add_argument("--output-file",  action="store", help ="destination output file",        required=True)
l_parser.add_argument("--min-percent",  action="store", help ="minimum coverage for success",   default=0, type=int)
l_result = l_parser.parse_args()

l_tree = ET.parse(l_result.input_file)
l_data = l_tree.findall(".")[0]
    
l_percent  = float(l_data.get("line-rate"))
l_percent  = int(l_percent * 100)

if l_result.output_file == "-":
  l_out = sys.stdout
else:
  l_out = open(l_result.output_file, "w")
  
l_status  = "success"
l_label   = "%d %%" % l_percent

if l_result.min_percent != 0:
  if int(l_percent) <  int(l_result.min_percent):
    l_status = "failure"
  
l_out.write(json.dumps({
  "status" : l_status,
  "label"  : l_label,
  "axes"   : {
    "percent" : l_percent
  }
}, indent=2))

# Local Variables:
# ispell-local-dictionary: "american"
# End:
