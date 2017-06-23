#!/usr/bin/python

import sys
import os
import json
import argparse
import xml.etree.ElementTree as ET


def target_matches(p_target, p_suppr):
  print("target : " + str(p_target))
  print("suppr  : " + str(p_suppr))
  return ((p_suppr["file"] == p_target["file"]) and
          (p_suppr["from"] <= p_target["from"]) and
          (p_suppr["to"]   >= p_target["to"]))


def target_found_in_supprs(p_target, p_supprs):
  for c_suppr in p_supprs:
    if target_matches(p_target, c_suppr):
      print("match")
      return True;
    print("no match")
  return False;

def targets_found_in_supprs(p_targets, p_supprs):
  for c_target in p_targets:
    if not target_found_in_supprs(c_target, p_supprs):
      return False
  return True;

def targets_found_in_directives(p_targets, p_directives):
  for c_directive in p_directives:
    if targets_found_in_supprs(p_targets, c_directive):
      return True
  return False;


l_parser = argparse.ArgumentParser()
l_parser.add_argument("--report",       action="store", help ="path to PMD xml report",           required=True)
l_parser.add_argument("--output",       action="store", help ="path to filtered report to write", required=True)
l_parser.add_argument("--supression",   action="store", help ="path to supression list",          required=True)
l_parser.add_argument("--basesrc",      action="store", help ="base directory of analysed files", required=True)
l_result = l_parser.parse_args()

l_data = []
if len(l_result.supression):
  l_suppFile = open(l_result.supression, "r")
  l_content  = l_suppFile.read().decode("utf-8")
  l_data     = json.loads(l_content)

l_base     = l_result.basesrc
l_intput   = open(l_result.report, "r")
l_tree     = ET.parse(l_intput)
l_dups     = l_tree.findall("./duplication")

for c_dup in l_dups:
  l_lines   = int(c_dup.get("lines", 0))
  l_files   = c_dup.findall("./file")
  l_targets = []
  for c_file in l_files:
    l_targets.append({
      u"from" : int(c_file.get("line", 0)),
      u"to"   : l_lines + int(c_file.get("line", 0)),
      u"file" : unicode(c_file.get("path", "").replace(l_base, "").lstrip("/"))
    })
  if targets_found_in_directives(l_targets, l_data):
    l_tree.getroot().remove(c_dup)
    pass

l_tree.write(l_result.output)


