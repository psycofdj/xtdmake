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

if l_result.output_file == "-":
  l_out = sys.stdout
else:
  l_out = open(l_result.output_file + ".tmp", "w")

l_total    = len(l_tree.findall("./httpSample"))             + len(l_tree.findall("./sample"))
l_success  = len(l_tree.findall("./httpSample[@s='true']"))  + len(l_tree.findall("./sample[@s='true']"))
l_failures = len(l_tree.findall("./httpSample[@s='false']")) + len(l_tree.findall("./sample[@s='false']"))

l_status  = "failure"
l_label   = "%d" % l_failures
if l_failures == 0:
  l_status = "success"
  
l_out.write(json.dumps({
  "kpi"    : "jmeter",
  "module" : l_result.module,
  "status" : l_status,
  "label"  : l_label,
  "index"  : "index.html",
  "data"   : {
    "success"  : l_success,
    "failures" : l_failures
  },
  "graphs" : [
        {
      "data": {
        "labels": [],
        "datasets": [
          {
            "borderColor": "rgba(179, 0, 0, 0.5)",
            "pointBorderColor": "rgba(102, 0, 0, 1)",
            "yAxisID": "absolute",
            "label": "jmeter: # failures",
            "backgroundColor": "rgba(179, 0, 0, 0.8)",
            "pointBackgroundColor": "rgba(102, 0, 0, 1)",
            "data": "%(failures)d"
          },
          {
            "borderColor": "rgba(51, 204, 51, 0.5)",
            "pointBorderColor": "rgba(31, 122, 31, 1)",
            "yAxisID": "absolute",
            "label": "jmeter: # success",
            "backgroundColor": "rgba(51, 204, 51, 0.8)",
            "pointBackgroundColor": "rgba(31, 122, 31, 1)",
            "data": "%(success)d"
          }
        ]
      },
      "type": "line",
      "options": {
        "scales": {
          "xAxes": [
            {
              "ticks": {
                "fontSize": 12,
                "minRotation": 80
              }
            }
          ],
          "yAxes": [
            {
              "position": "left",
              "ticks": {
                "fontSize": 24,
                "beginAtZero": True
              },
              "type": "linear",
              "id": "absolute",
              "display": True
            }
          ]
        },
        "title": {
          "text": "jmeter",
          "display": True
        }
      }
    }
  ]
}, indent=2))
l_out.close()
os.rename(l_result.output_file + ".tmp", l_result.output_file)

# Local Variables:
# ispell-local-dictionary: "en"
# End:
