#!/usr/bin/python

import sys
import os
import json
import argparse
import xml.etree.ElementTree as ET

l_parser = argparse.ArgumentParser()
l_parser.add_argument("--module",       action="store", help ="current module name",       required=True)
l_parser.add_argument("--input-file",   action="store", help ="path to xml check results", required=True)
l_parser.add_argument("--output-file",  action="store", help ="destination output file",   required=True)
l_result = l_parser.parse_args()

l_tree    = ET.parse(l_result.input_file)
l_tests   = l_tree.findall("./duplication")

if l_result.output_file == "-":
  l_out = sys.stdout
else:
  l_out = open(l_result.output_file + ".tmp", "w")

l_status  = "failure"
l_label   = "%d" % len(l_tests)
if len(l_tests) == 0:
  l_status = "success"

l_out.write(json.dumps({
  "kpi"    : "codedup",
  "module" : l_result.module,
  "status" : l_status,
  "label"  : l_label,
  "index"  : "index.html",
  "data"   : {
    "total" : len(l_tests)
  },
  "graphs" : [
    {
      "type"   : "line",
      "data"   : {
        "labels"   : [],
        "datasets" : [
          {
            "yAxisID" : "absolute",
            "label"   : "codedup: # error count",
            "data"    : "%(total)d",
            "borderColor" : "rgba(179, 0, 0, 0.5)",
            "backgroundColor" : "rgba(179, 0, 0, 0.5)",
            "pointBorderColor" : "rgba(102, 0, 0, 1)",
            "pointBackgroundColor" : "rgba(102, 0, 0, 1)"
          }
        ]
      },
      "options" : {
        "title" : {
          "text" : "%(module)s : codedup",
          "display" : True
        },
        "scales" : {
          "xAxes" : [{
            "ticks" : {
              "minRotation" : 80,
              "fontSize": 12
            }
          }],
          "yAxes" : [
            {
              "id"     : "absolute",
              "type"     : "linear",
              "position" : "left",
              "display": True,
              "ticks": {
                "beginAtZero": True,
                "fontSize" : 24
              }
            }
          ]
        }
      }
    }
  ]
}, indent=2))
l_out.close()
os.rename(l_result.output_file + ".tmp", l_result.output_file)
