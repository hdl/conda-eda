#!/usr/bin/env python3

import io
import pexpect
import re
import string
import sys
import time

output_to=sys.stdout

args = list(sys.argv[1:])
logfile = open(args.pop(0), "w")
child = pexpect.spawn(' '.join(args))

def output_line(line_bits, last_skip):
  line = "".join(line_bits)
  line = re.sub("/really.*/conda/", "/.../conda/", line)
  line = re.sub("/_b_env_[^/]*/", "/_b_env_.../", line)
  sline = line.strip()

  skip = True
  if line.startswith(" ") and not sline.startswith('/'):
    skip = False

  if "da es fi" in sline:
    skip = True
  if "setting rpath" in sline:
    skip = True
  if "fprintf" in sline:
    skip = True
  if " from " in sline:
    skip = True
  if "if (" in sline:
    skip = True

  if "Entering directory" in sline:
    skip = False
    sline = sline.split('make')[-1]

  if re.search("[0-9]+\.[0-9]+", line) and "PACKAGE_" not in line and "SRC_DIR" not in line:
    skip = False

  if len(sline) > 1:
    if sline[0] in string.ascii_uppercase and sline[1] not in string.ascii_uppercase:
      skip = False
    if sline[0] in ('[', '=', '!', '+'):
      skip = False

  if skip != last_skip:
    output_to.write('\n')

  if skip:
    output_to.write('.')
  else:
    output_to.write(line)

  output_to.flush()
  line_bits.clear()
  return skip


def find_newline(data):
  fulldata = b"".join(data)
  newlinechar = fulldata.find(b'\n')
  retlinechar = fulldata.find(b'\r')

  if newlinechar == -1:
    newlinechar = len(fulldata)+1
  if retlinechar == -1:
    retlinechar = len(fulldata)+1

  if retlinechar+1 == newlinechar:
    splitpos = newlinechar
  else:
    splitpos = min(newlinechar, retlinechar)

  if splitpos > len(fulldata):
    return

  newline = fulldata[:splitpos+1]
  leftover = fulldata[splitpos+1:]

  data.clear()
  data.append(leftover)
  return newline


last_skip = False
cont = []
data = [b'']
while True:
  line = None
  while len(data) > 1 or len(data[0]) > 0 or child.isalive():
    line = find_newline(data)
    if line is not None:
      break
    try:
      data.append(child.read_nonblocking(100))
    except pexpect.TIMEOUT:
      pass
    except pexpect.EOF as e:
      data.append(b'\n')

  if not line:
    break

  line = line.decode('utf-8', errors='backslashreplace')

  logfile.write(line)
  logfile.flush()

  if line.endswith('\r'):
    cont.append(line[:-1])
    last_skip = output_line(cont, last_skip)
    cont.append('\r')
    continue

  sline = line.strip('\n\r')
  cont.append(sline)
  if sline.endswith('\\'):
    continue

  cont.append('\n')
  last_skip = output_line(cont, last_skip)

sys.exit(child.exitstatus)
