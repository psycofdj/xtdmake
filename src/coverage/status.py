#!/usr/bin/python

import sys
import os
import json
import argparse
import xml.etree.ElementTree as ET

l_parser = argparse.ArgumentParser()
l_parser.add_argument("--module",       action="store", help ="current module name",            required=True)
l_parser.add_argument("--input-file",   action="store", help ="path to xml results",            required=True)
l_parser.add_argument("--output-file",  action="store", help ="destination output file",        required=True)
l_parser.add_argument("--min-percent",  action="store", help ="minimum coverage for success",   default=0, type=int)
l_result = l_parser.parse_args()

l_tree = ET.parse(l_result.input_file)
l_data = l_tree.findall(".")[0]

l_total    = int(l_data.get("lines-valid"))
l_covered  = int(l_data.get("lines-covered"))
l_percent  = float(l_data.get("line-rate"))
l_percent  = int(l_percent * 100)

if l_result.output_file == "-":
  l_out = sys.stdout
else:
  l_out = open(l_result.output_file + ".tmp", "w")
  
l_status  = "success"
l_label   = "%d %%" % l_percent

if l_result.min_percent != 0:
  if int(l_percent) <  int(l_result.min_percent):
    l_status = "failure"
  
l_out.write(json.dumps({
  "kpi"    : "coverage",
  "module" : l_result.module,
  "status" : l_status,
  "index"  : "index.html",
  "label"  : l_label,
  "data" : {
    "covered" : l_covered,
    "total"   : l_total,
    "percent" : "int((float(%(covered)d) / float(%(total)d)) * 100)"
  },
  "graphs" : [
    {
      "type"   : "line",
      "data"   : {
        "labels"   : [],
        "datasets" : [
          {
            "yAxisID" : "absolute",
            "label"   : "coverage: # covered lines",
            "data"    : "%(covered)d",
            "borderColor" : "rgba(51, 204, 51, 0.5)",
            "backgroundColor" : "rgba(51, 204, 51, 0)",
            "pointBorderColor" : "rgba(31, 122, 31, 1)",
            "pointBackgroundColor" : "rgba(31, 122, 31, 1)"
          },
          {
            "yAxisID" : "absolute",
            "label"   : "coverage: # total lines",
            "data"    : "%(total)d",
            "borderColor" : "rgba(179, 0, 0, 0.5)",
            "backgroundColor" : "rgba(179, 0, 0, 0)",
            "pointBorderColor" : "rgba(102, 0, 0, 1)",
            "pointBackgroundColor" : "rgba(102, 0, 0, 1)"
          },
          {
            "yAxisID" : "percent",
            "label"   : "coverage: % covered lines",
            "data"    : "int((float(%(covered)d) / float(%(total)d)) * 100)",
            "borderColor" : "rgba(102, 153, 255, 0.5)",
            "backgroundColor" : "rgba(102, 153, 255, 0)",
            "pointBorderColor" : "rgba(0, 60, 179, 1)",
            "pointBackgroundColor" : "rgba(0, 60, 179, 1)"
          }
        ]
      },
      "options" : {
        "title" : {
          "text" : "%(module)s : coverage",
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
  ]
}, indent=2))
l_out.close()
os.rename(l_result.output_file + ".tmp", l_result.output_file)

# Local Variables:
# ispell-local-dictionary: "american"
# End:
