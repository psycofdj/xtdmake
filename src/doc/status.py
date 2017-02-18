#!/usr/bin/python

import sys
import os
import json
import argparse
import xml.etree.ElementTree as ET

l_parser = argparse.ArgumentParser()
l_parser.add_argument("--module",       action="store", help ="current module name",            required=True)
l_parser.add_argument("--output-file",  action="store", help ="destination output file",        required=True)
l_result = l_parser.parse_args()

if l_result.output_file == "-":
  l_out = sys.stdout
else:
  l_out = open(l_result.output_file + ".tmp", "w")
  
l_out.write(json.dumps({
  "kpi"    : "doc",
  "module" : l_result.module,
  "status" : "success",
  "label"  : "ok",
  "index"  : "html/index.html",
  "data"   : {},
  "graphs" : []
}, indent=2))
l_out.close()
os.rename(l_result.output_file + ".tmp", l_result.output_file)

# Local Variables:
# ispell-local-dictionary: "american"
# End:
