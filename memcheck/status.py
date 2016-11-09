#!/usr/bin/python

import sys
import os
import json
import argparse

l_parser = argparse.ArgumentParser()
l_parser.add_argument("--input-file",   action="store", help ="path to xml check results",      required=True)
l_parser.add_argument("--output-file",  action="store", help ="destination output file",        required=True)
l_parser.add_argument("--min-percent",  action="store", help ="minimum coverage for success",   default=0, type=int)
l_result = l_parser.parse_args()

l_file = open(l_result.input_file, "r")
l_content = l_file.read()
l_data = json.loads(l_content)

l_total = 0

for c_item in l_data["tests"]:
  l_total += len(c_item["errors"])

if l_result.output_file == "-":
  l_out = sys.stdout
else:
  l_out = open(l_result.output_file, "w")
                 
l_status  = "failure"
l_label   = "%d" % l_total
                 
if l_total == 0:
  l_status = "success"
  
l_out.write(json.dumps({
  "status" : l_status,
  "label"  : l_label,
  "graphs" : [
    {
      "name" : "memcheck - errors",
      "series" : [ "total"  ]
    }
  ],
  "data" : {
    "total" : l_total
  }
}, indent=2))

# Local Variables:
# ispell-local-dictionary: "american"
# End:
