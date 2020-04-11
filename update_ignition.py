#!/usr/bin/python3

import json

def merge_okd_ignition_with_additional_ignition(data_okd_ignition: json, data_additional_ignition: json) -> json:
  """
    Merge data_okd_ignition with data_additional_ignition
    Only passwd > users and storage > files are merged
  """
  if 'passwd' in data_additional_ignition and 'users' in data_additional_ignition['passwd']:
    if 'passwd' not in data_okd_ignition:
      data_okd_ignition['passwd'] = {}
      data_okd_ignition['passwd']['users'] = []
    if 'users' not in data_okd_ignition['passwd']:
      data_okd_ignition['passwd']['users'] = []
    data_okd_ignition['passwd']['users'].extend(data_additional_ignition['passwd']['users'])

  return data_okd_ignition
