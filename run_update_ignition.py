#!/usr/bin/python3

import sys
import getopt
import json

from update_ignition import merge_okd_ignition_with_additional_ignition

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

with open(input_ign_created_file, "r") as data_ign_created_file, open(input_additional_configuration_file, "r") as data_additional_configuration_file:
  okd_ignition_merged = merge_okd_ignition_with_additional_ignition(json.load(data_ign_created_file), json.load(data_additional_configuration_file))
  data_ign_created_file.close()
  data_additional_configuration_file.close()

with open(input_ign_created_file, "w") as data_ign_created:
  data_ign_created.write(json.dumps(okd_ignition_merged, indent=4))
  data_ign_created.close()
