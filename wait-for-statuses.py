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

numOfJobs = int(os.environ['NUM_OF_JOBS'])

while(True):
  time.sleep(60)
  countCompleted = 0

  with urllib.request.urlopen(status_url) as url:
    data = json.loads(url.read().decode())
    for j in data["jobs"]:
      if(j["status"] == "completed"):
        countCompleted += 1

  print("Completed jobs:" + str(countCompleted) + ". Jobs overall: " + str(numOfJobs))
  if(countCompleted >= numOfJobs):
    break

subprocess.call(os.environ['GITHUB_WORKSPACE'] + "/.github/scripts/master-package.sh")
subprocess.call(os.environ['GITHUB_WORKSPACE'] + "/.github/scripts/cleanup-anaconda.sh")

