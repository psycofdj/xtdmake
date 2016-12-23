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
l_documented = 0
for c_item in l_data:
  for c_name, c_syms in c_item.items():
    for c_sym in c_syms:
      l_total += 1
      if c_sym["documented"]:
        l_documented += 1

l_percent  = float(l_documented) / float(l_total)
l_percent  = int(l_percent * 100.0)

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
  "graphs" : [
    {
      "type"   : "line",
      "data"   : {
        "labels"   : [],
        "datasets" : [
          {
            "yAxisID" : "absolute",
            "label"   : "documented lines",
            "data"    : "%(documented)d",
            "borderColor" : "rgba(51, 204, 51, 0.5)",
            "backgroundColor" : "rgba(51, 204, 51, 0)",
            "pointBorderColor" : "rgba(31, 122, 31, 1)",
            "pointBackgroundColor" : "rgba(31, 122, 31, 1)"
          },
          {
            "yAxisID" : "absolute",
            "label"   : "total lines",
            "data"    : "%(total)d",
            "borderColor" : "rgba(179, 0, 0, 0.5)",
            "backgroundColor" : "rgba(179, 0, 0, 0)",
            "pointBorderColor" : "rgba(102, 0, 0, 1)",
            "pointBackgroundColor" : "rgba(102, 0, 0, 1)"
          },
          {
            "yAxisID" : "percent",
            "label"   : "% covered lines",
            "data"    : "int((float(%(documented)d) / float(%(total)d)) * 100)",
            "borderColor" : "rgba(102, 153, 255, 0.5)",
            "backgroundColor" : "rgba(102, 153, 255, 0)",
            "pointBorderColor" : "rgba(0, 60, 179, 1)",
            "pointBackgroundColor" : "rgba(0, 60, 179, 1)"
          }
        ]
      },
      "options" : {
        "title" : {
          "text" : "%(module)s : doc-coverage",
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
            },
            {
              "id"     : "percent",
              "type"     : "linear",
              "position" : "right",
              "ticks": {
                "beginAtZero" : True,
                "fontSize"    : 24,
                "max"         : 100
              }
            }
          ]
        }
      }
    }
  ],
  "data" : {
    "documented" : l_documented,
    "total"      : l_total
  }
}, indent=2))

# Local Variables:
# ispell-local-dictionary: "american"
# End: