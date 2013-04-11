#!/usr/bin/python
#
# Coldfusion Password Tool
# Copyright (C) 2013 Adam Boeglin <adamrb@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


import hashlib
import pyDes
import base64
import sys, getopt
import unicodedata, re

# The Default Coldfusion Encryption Key
cfkey = "0yJ!@1$r8p0L@r1$6yJ!@1rj"

# Strip non printable characters from output
# From http://stackoverflow.com/questions/92438/stripping-non-printable-characters-from-a-string-in-python
control_chars = ''.join(map(unichr, range(0,32) + range(127,160)))
control_char_re = re.compile('[%s]' % re.escape(control_chars))

def usage():
    print sys.argv[0] + " usage: [-d] [-e] [-u]"
    print '''
options:
  -h, --help      Show this help message and exit
  -d, --decrypt   Decrypt a 3DES encrypted Coldfusion Password (eg from neo-datasource.xml)
  -e, --encrypt   Encrypt a password to be used in a ColdFusion datasource (neo-datasource.xml)
  -u, --userpass  Encrypt a username to be used in a ColdFusion security file (neo-security.xml)
'''

def remove_control_chars(s):
      return control_char_re.sub('', s)

# Decrypt a Base64 encoded 3DES encrypted String
def decryptpass(str):
    mykey = pyDes.triple_des(cfkey)
    decrypted = mykey.decrypt(base64.decodestring(str), "*")
    cleanpass = remove_control_chars(decrypted)
    print cleanpass

# Encrypt and Base64 encode a string
def encryptpass(str):
    mykey = pyDes.triple_des(cfkey)
    encrypted = base64.b64encode(mykey.encrypt( str, "*"))

    print encrypted

# SHA1 Encrypt a string
def encryptuser(str):
    myhash = hashlib.sha1()
    myhash.update(str)
    print(myhash.hexdigest().upper())

# Main
def main(argv):
    # Exit if no arguments given
    if len(sys.argv) == 1:
        usage()
        sys.exit(2)

    # Get Options and run functions
    try:
      opts, args = getopt.getopt(argv,"hd:e:u:",["decrypt=","encrypt=","userpass="])
    except getopt.GetoptError:
      usage()
      sys.exit(2)
    for opt, arg in opts:
      if opt in ('-h', "--help"):
         usage()
         sys.exit()
      elif opt in ("-d", "--decrypt"):
         decryptpass(arg)
      elif opt in ("-e", "--encrypt"):
         encryptpass(arg)
      elif opt in ("-u", "--userpass"):
         encryptuser(arg)

if __name__ == "__main__":
   main(sys.argv[1:])
