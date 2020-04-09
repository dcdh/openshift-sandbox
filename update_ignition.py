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

with open(input_additional_configuration_file, "r") as data_additional_configuration:


TODO merge !!!

with open(input_ign_created_file, "r") as data_ign_created:
  data = json.load(data_ign_created)

  if hasattr(data, "passwd") is False:
    data["passwd"] = {}
    data["passwd"]["users"] = []
  if hasattr(data["passwd"], "users") is False:
    data["passwd"]["users"] = []

  data["passwd"]["users"].append({
    "name": user,
    "sshAuthorizedKeys": [
      sshPublicKey
    ],
    "groups": [
      "sudo",
      "docker"
    ]
  })
  ign_created_file.close()

with open(input_ign_created_file, "w") as ign_created_file:
  json.dump(data, ign_created_file)
  ign_created_file.close()
