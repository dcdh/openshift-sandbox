#!/usr/bin/python3

import unittest

from update_ignition import merge_okd_ignition_with_additional_ignition

class TestFonctionMergeOkdIgnitionWithAdditionalIgnition(unittest.TestCase):

  def test_should_add_passwd_users_when_passwd_not_present_in_okd_ignition(self) -> None:
    # Given
    okd_ignition = {
      'ignition': {
        'security': {},
        'version': '3.0.0',
        'config': {}
      }
    }
    additional_ignition = {
      'passwd': {
        'users': [
          {
            'sshAuthorizedKeys': [
              'ssh-rsa ...'
            ],
            'name': 'damien',
            'groups': [
              'sudo',
              'docker'
            ]
          }
        ]
      },
      'ignition': {
        'security': {},
        'version': '3.0.0',
        'config': {}
      }
    }

    # When
    merged_ignitions = merge_okd_ignition_with_additional_ignition(okd_ignition, additional_ignition)

    # Then
    self.assertEqual(merged_ignitions, {
      'passwd': {
        'users': [
          {
            'sshAuthorizedKeys': [
              'ssh-rsa ...'
            ],
            'name': 'damien',
            'groups': [
              'sudo',
              'docker'
            ]
          }
        ]
      },
      'ignition': {
        'security': {},
        'version': '3.0.0',
        'config': {}
      }
    })

  def test_should_add_passwd_users_when_passwd_is_present_in_okd_ignition(self) -> None:
    # Given
    okd_ignition = {
        'passwd': {
        'users': [
          {
            'sshAuthorizedKeys': [
              'ssh-rsa ...'
            ],
            'name': 'core'
          }
        ]
      },
      'ignition': {
        'security': {},
        'version': '3.0.0',
        'config': {}
      }
    }
    additional_ignition = {
      'passwd': {
        'users': [
          {
            'sshAuthorizedKeys': [
              'ssh-rsa ...'
            ],
            'name': 'damien',
            'groups': [
              'sudo',
              'docker'
            ]
          }
        ]
      },
      'ignition': {
        'security': {},
        'version': '3.0.0',
        'config': {}
      }
    }

    # When
    merged_ignitions = merge_okd_ignition_with_additional_ignition(okd_ignition, additional_ignition)

    # Then
    self.assertEqual(merged_ignitions, {
      'passwd': {
        'users': [
          {
            'sshAuthorizedKeys': [
              'ssh-rsa ...'
            ],
            'name': 'core'
          },
          {
            'sshAuthorizedKeys': [
              'ssh-rsa ...'
            ],
            'name': 'damien',
            'groups': [
              'sudo',
              'docker'
            ]
          }
        ]
      },
      'ignition': {
        'security': {},
        'version': '3.0.0',
        'config': {}
      }
    })

if __name__ == '__main__':
    unittest.main()