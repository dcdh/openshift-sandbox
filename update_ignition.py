#!/usr/bin/python

import sys
import getopt
import json

ignCreatedFile=None
user=None
sshPublicKey=None

myopts, args = getopt.getopt(sys.argv[1:],"", [
  "ign-created-file=", "user=", "ssh-public-key="
])

for o, a in myopts:
  if o == '--ign-created-file':
    ignCreatedFile=a
  elif o == '--user':
    user=a
  elif o == '--ssh-public-key':
    sshPublicKey=a

if ignCreatedFile is None:
  raise TypeError("Missing ign created file")

if user is None:
  raise TypeError("Missing user")

if sshPublicKey is None:
  raise TypeError("Missing ssh public key")

with open(ignCreatedFile, "r") as ign_created_file:
  data = json.load(ign_created_file)

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

with open(ignCreatedFile, "w") as ign_created_file:
  json.dump(data, ign_created_file)
  ign_created_file.close()
