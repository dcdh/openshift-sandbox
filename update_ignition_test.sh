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

  def test_should_add_storage_files_when_storage_not_present_in_okd_ignition(self) -> None:
    self.maxDiff = None
    # Given
    okd_ignition = {
      'ignition': {
        'security': {},
        'version': '3.0.0',
        'config': {}
      }
    }
    additional_ignition = {
      'storage': {
        'files': [
          {
            'group': {},
            'overwrite': 'true',
            'path': '/etc/containers/registries.conf',
            'user': {},
            'contents': {
              'source': 'data:,%5B%5Bregistry%5D%5D%0Aprefix%20%3D%20%22quay.io%2Fopenshift%22%0Alocation%20%3D%20%22quay.io%2Fopenshift%22%0Amirror-by-digest-only%20%3D%20true%0A%0A%20%20%5B%5Bregistry.mirror%5D%5D%0A%20%20location%20%3D%20%22container-registry.ocp4-cluster-001.sandbox.okd%2Fopenshift%22%0A%20%20insecure%20%3D%20true%0A',
              'verification': {}
            }
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
      'storage': {
        'files': [
          {
            'group': {},
            'overwrite': 'true',
            'path': '/etc/containers/registries.conf',
            'user': {},
            'contents': {
              'source': 'data:,%5B%5Bregistry%5D%5D%0Aprefix%20%3D%20%22quay.io%2Fopenshift%22%0Alocation%20%3D%20%22quay.io%2Fopenshift%22%0Amirror-by-digest-only%20%3D%20true%0A%0A%20%20%5B%5Bregistry.mirror%5D%5D%0A%20%20location%20%3D%20%22container-registry.ocp4-cluster-001.sandbox.okd%2Fopenshift%22%0A%20%20insecure%20%3D%20true%0A',
              'verification': {}
            }
          }
        ]
      },
      'ignition': {
        'security': {},
        'version': '3.0.0',
        'config': {}
      }
    })

  def test_should_add_storage_files_when_storage_is_present_in_okd_ignition(self) -> None:
    self.maxDiff = None
    # Given
    okd_ignition = {
      'storage': {
        'files': [
          {
            'contents': {
              'source': 'data:text/plain;charset=utf-8;base64,LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURFRENDQWZpZ0F3SUJBZ0lJQ3gzTHRmc3BJdXd3RFFZSktvWklodmNOQVFFTEJRQXdKakVTTUJBR0ExVUUKQ3hNSmIzQmxibk5vYVdaME1SQXdEZ1lEVlFRREV3ZHliMjkwTFdOaE1CNFhEVEl3TURRd09USXpNRFF3TUZvWApEVE13TURRd056SXpNRFF3TUZvd0pqRVNNQkFHQTFVRUN4TUpiM0JsYm5Ob2FXWjBNUkF3RGdZRFZRUURFd2R5CmIyOTBMV05oTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF6SU9IOW5FZkcyS0UKK0cvK0svSzRJekFxYnl2NXpuczk3MFpWRnk2TmZaTE9LeXQzbjNwYWZIQmsxWVpHam00cVhhWG8yQ3ZpdFE5TApBSVh5RUkyK2VGdXl6cXV3NHpNa0tySEoxMElpajliamtPbGlVWUVWWjVQQXRDRVlJeWtCS2k2Qno1bkNxMGZ4CndldmlPeTE2cWtmaURhNGtnVDRrSkw5c0NlQUh4V01obzRiRG5PNzNhdmMxY2ZNc2lsYjJkYkxqOTJaekdWdmEKZVoxTTZtQ3huS2ZPcURDdXNRYmZrS3BhK3AwSk1OYXdlQ2ZJc3VkbDNKdHB6V3lIbmF5cG02b0NUQTJwMW9nOApYdDhmMUNmNEhHeE1XajM1NWlFamYxRG1kQk5kaVh2MUFvWDNWU3JvV1M2YzVacjNqQkpGTnkrZEhTTHlZNmNKCk1VaHBwUWZWZXdJREFRQUJvMEl3UURBT0JnTlZIUThCQWY4RUJBTUNBcVF3RHdZRFZSMFRBUUgvQkFVd0F3RUIKL3pBZEJnTlZIUTRFRmdRVXBkeTB1cWxLRjZNbjBHZkVNSm1iKzR5RGNSZ3dEUVlKS29aSWh2Y05BUUVMQlFBRApnZ0VCQUE1VTBiek92ZFlPWDEwSC9NSmxwR3RZRnR1b0grTkM0QU1kUXJ3cDRrSUd6dm1EcEEvRXpzSHFTc1RzCnU0MU1BOTY2c0ZZMUxrM1pFQy8wTCtjYkFaSkxWeWlETmhnY2hpME9hdTBGb2cwcVArTkoyNUhLVDlOeXFkN0gKZ3NyMDVOVERxa2x1dWFPdktWRk14MTRua1VZZDUvN1pmOTA2cjBheFRxZlRuMDkrcHRuZThEL2k1Nmc0aFlYbwo5QTkxcVowRnFHQ0hwZEs1dkxGdWp3RzhnUFpETk5PdFNOK1FtSy9lMWV5Um9vY0I2MG10V205U0NSdVlnTDVsClZiRjJNcE9Ta1pvV3ZxaGZ6NGduVm8vUlZNejRBYWYvQkNSMk10UUxpejREOS9vZlc1ZFZhRW94aGFzcEZEaXAKa2VuZ1prMkZFQ01taE53TmhuVWpmRlFRNmFvPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=='
            },
            'mode': 420,
            'overwrite': 'true',
            'path': '/opt/openshift/tls/root-ca.crt',
            'user': {
              'name': 'root'
            }
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
      'storage': {
        'files': [
          {
            'group': {},
            'overwrite': 'true',
            'path': '/etc/containers/registries.conf',
            'user': {},
            'contents': {
              'source': 'data:,%5B%5Bregistry%5D%5D%0Aprefix%20%3D%20%22quay.io%2Fopenshift%22%0Alocation%20%3D%20%22quay.io%2Fopenshift%22%0Amirror-by-digest-only%20%3D%20true%0A%0A%20%20%5B%5Bregistry.mirror%5D%5D%0A%20%20location%20%3D%20%22container-registry.ocp4-cluster-001.sandbox.okd%2Fopenshift%22%0A%20%20insecure%20%3D%20true%0A',
              'verification': {}
            }
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
      'storage': {
        'files': [
          {
            'contents': {
              'source': 'data:text/plain;charset=utf-8;base64,LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURFRENDQWZpZ0F3SUJBZ0lJQ3gzTHRmc3BJdXd3RFFZSktvWklodmNOQVFFTEJRQXdKakVTTUJBR0ExVUUKQ3hNSmIzQmxibk5vYVdaME1SQXdEZ1lEVlFRREV3ZHliMjkwTFdOaE1CNFhEVEl3TURRd09USXpNRFF3TUZvWApEVE13TURRd056SXpNRFF3TUZvd0pqRVNNQkFHQTFVRUN4TUpiM0JsYm5Ob2FXWjBNUkF3RGdZRFZRUURFd2R5CmIyOTBMV05oTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF6SU9IOW5FZkcyS0UKK0cvK0svSzRJekFxYnl2NXpuczk3MFpWRnk2TmZaTE9LeXQzbjNwYWZIQmsxWVpHam00cVhhWG8yQ3ZpdFE5TApBSVh5RUkyK2VGdXl6cXV3NHpNa0tySEoxMElpajliamtPbGlVWUVWWjVQQXRDRVlJeWtCS2k2Qno1bkNxMGZ4CndldmlPeTE2cWtmaURhNGtnVDRrSkw5c0NlQUh4V01obzRiRG5PNzNhdmMxY2ZNc2lsYjJkYkxqOTJaekdWdmEKZVoxTTZtQ3huS2ZPcURDdXNRYmZrS3BhK3AwSk1OYXdlQ2ZJc3VkbDNKdHB6V3lIbmF5cG02b0NUQTJwMW9nOApYdDhmMUNmNEhHeE1XajM1NWlFamYxRG1kQk5kaVh2MUFvWDNWU3JvV1M2YzVacjNqQkpGTnkrZEhTTHlZNmNKCk1VaHBwUWZWZXdJREFRQUJvMEl3UURBT0JnTlZIUThCQWY4RUJBTUNBcVF3RHdZRFZSMFRBUUgvQkFVd0F3RUIKL3pBZEJnTlZIUTRFRmdRVXBkeTB1cWxLRjZNbjBHZkVNSm1iKzR5RGNSZ3dEUVlKS29aSWh2Y05BUUVMQlFBRApnZ0VCQUE1VTBiek92ZFlPWDEwSC9NSmxwR3RZRnR1b0grTkM0QU1kUXJ3cDRrSUd6dm1EcEEvRXpzSHFTc1RzCnU0MU1BOTY2c0ZZMUxrM1pFQy8wTCtjYkFaSkxWeWlETmhnY2hpME9hdTBGb2cwcVArTkoyNUhLVDlOeXFkN0gKZ3NyMDVOVERxa2x1dWFPdktWRk14MTRua1VZZDUvN1pmOTA2cjBheFRxZlRuMDkrcHRuZThEL2k1Nmc0aFlYbwo5QTkxcVowRnFHQ0hwZEs1dkxGdWp3RzhnUFpETk5PdFNOK1FtSy9lMWV5Um9vY0I2MG10V205U0NSdVlnTDVsClZiRjJNcE9Ta1pvV3ZxaGZ6NGduVm8vUlZNejRBYWYvQkNSMk10UUxpejREOS9vZlc1ZFZhRW94aGFzcEZEaXAKa2VuZ1prMkZFQ01taE53TmhuVWpmRlFRNmFvPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=='
            },
            'mode': 420,
            'overwrite': 'true',
            'path': '/opt/openshift/tls/root-ca.crt',
            'user': {
              'name': 'root'
            }
          },
          {
            'group': {},
            'overwrite': 'true',
            'path': '/etc/containers/registries.conf',
            'user': {},
            'contents': {
              'source': 'data:,%5B%5Bregistry%5D%5D%0Aprefix%20%3D%20%22quay.io%2Fopenshift%22%0Alocation%20%3D%20%22quay.io%2Fopenshift%22%0Amirror-by-digest-only%20%3D%20true%0A%0A%20%20%5B%5Bregistry.mirror%5D%5D%0A%20%20location%20%3D%20%22container-registry.ocp4-cluster-001.sandbox.okd%2Fopenshift%22%0A%20%20insecure%20%3D%20true%0A',
              'verification': {}
            }
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