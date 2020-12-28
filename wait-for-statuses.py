import urllib.request
import json
import subprocess
import time
import os

status_url = "https://api.github.com/repos/" \
         + os.environ['GITHUB_REPOSITORY'] \
         + "/actions/runs/" \
         + os.environ['GITHUB_RUN_ID'] \
         + "/jobs"

while(True):
  time.sleep(60)
  success = True
  with urllib.request.urlopen(status_url) as url:
    data = json.loads(url.read().decode())
    for j in data["jobs"]:
      if(j["status"] != "completed" and j["name"] != "master-package"):
        success = False
  if(success):
    break

subprocess.call(os.environ['GITHUB_WORKSPACE'] + "/.github/scripts/master-package.sh")
