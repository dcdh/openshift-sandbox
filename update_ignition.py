#!/usr/bin/python

# TODO faire des tests !!!

import sys
import getopt
import json

input_ign_created_file=None
input_additional_configuration_file=None

myopts, args = getopt.getopt(sys.argv[1:],"", [
  "ign-created-file=", "additional-configuration-file="
])

for o, a in myopts:
  if o == '--ign-created-file':
    input_ign_created_file=a
  elif o == '--additional-configuration-file':
    input_additional_configuration_file=a

if input_ign_created_file is None:
  raise TypeError("Missing ign created file")

if input_additional_configuration_file is None:
  raise TypeError("Missing additional configuration file")

with open(input_ign_created_file, "r") as data_ign_created, open(input_additional_configuration_file, "r") as data_additional_configuration:
  data_to_merge_to = json.load(data_ign_created)
  data_to_merge_from = json.load(data_additional_configuration)

  if hasattr(data_to_merge_to, "passwd") is False:
    data_to_merge_to["passwd"] = {}
    data_to_merge_to["passwd"]["users"] = []
  if hasattr(data_to_merge_to["passwd"], "users") is False:
    data_to_merge_to["passwd"]["users"] = []

  data_to_merge_to["passwd"]["users"].append(data_to_merge_from["passwd"]["users"])

  if hasattr(data_to_merge_to, "storage") is False:
    data_to_merge_to["storage"] = {}
    data_to_merge_to["storage"]["files"] = []
  if hasattr(data_to_merge_to["storage"], "files") is False:
    data_to_merge_to["storage"]["files"] = []

  data_to_merge_to["storage"]["files"].append(data_to_merge_from["storage"]["files"])

  data_ign_created.close()
  data_additional_configuration.close()

with open(input_ign_created_file, "w") as data_ign_created:
  json.dump(data_to_merge_to, data_ign_created)
  data_ign_created.close()
