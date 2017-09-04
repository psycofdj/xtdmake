#!/usr/bin/python

import sys
import os
import json
import argparse
from mako.template import Template


l_parser = argparse.ArgumentParser()
l_parser.add_argument("--module",        action="store", help ="current module name",       required=True)
l_parser.add_argument("--input-file",    action="store", help ="path to json results",      required=True)
l_parser.add_argument("--output-status", action="store", help ="status destination file",   required=True)
l_parser.add_argument("--output-html",   action="store", help ="html destination file",   required=True)
l_result = l_parser.parse_args()


l_inFile = open(l_result.input_file, "r")
l_content = l_inFile.read()
l_data    = json.loads(l_content)

l_tplPath  = os.path.join(os.path.dirname(os.path.abspath(__file__)), "index.tpl")
l_tpl      = Template(filename=l_tplPath)
l_content  = l_tpl.render(items=l_data)
l_htmlFile = open(l_result.output_html, "w")
l_htmlFile.write(l_content)


l_out        = open(l_result.output_status + ".tmp", "w")
l_total      = len(l_data)
l_success    = len({ x:y for x,y in l_data.items() if y["errors"] == False and y["full"] == [] })
l_failures   = len({ x:y for x,y in l_data.items() if y["errors"] == False and y["full"] != [] })
l_errors     = len({ x:y for x,y in l_data.items() if y["errors"] == True })

l_label   = "%d" % l_failures
if l_failures == 0:
  if l_errors == 0:
    l_status = "success"
  else:
    l_status = "warning"
else:
  l_status  = "failure"

l_out.write(json.dumps({
  "kpi"    : "iwyu",
  "module" : l_result.module,
  "status" : l_status,
  "label"  : l_label,
  "index"  : "index.html",
  "data"   : {
    "success"  : l_success,
    "failures" : l_failures,
    "errors"   : l_errors,
  },
  "graphs" : [
        {
      "data": {
        "labels": [],
        "datasets": [
          {
            "borderColor": "rgba(179, 0, 0, 0.5)",
            "pointBorderColor": "rgba(102, 0, 0, 1)",
            "yAxisID": "failure",
            "label": "iwyu: # failures",
            "backgroundColor": "rgba(179, 0, 0, 0)",
            "pointBackgroundColor": "rgba(102, 0, 0, 1)",
            "data": "%(failures)d"
          },
          {
            "borderColor": "rgba(51, 204, 51, 0.5)",
            "pointBorderColor": "rgba(31, 122, 31, 1)",
            "yAxisID": "success",
            "label": "iwyu: # success",
            "backgroundColor": "rgba(51, 204, 51, 0)",
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
                "fontSize": 24
              },
              "type": "linear",
              "id": "success",
              "display": True
            },
            {
              "position": "right",
              "ticks": {
                "fontSize": 24,
                "beginAtZero": True
              },
              "type": "linear",
              "id": "failure",
              "display": True
            }
          ]
        },
        "title": {
          "text": "iwyu",
          "display": True
        }
      }
    }
  ]
}, indent=2))
l_out.close()
os.rename(l_result.output_status + ".tmp", l_result.output_status)

# Local Variables:
# ispell-local-dictionary: "en"
# End:
