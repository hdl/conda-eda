import urllib.request
import json
import subprocess
import time
import os
import sys

# We're limited to this number by GH Actions API
# https://docs.github.com/en/free-pro-team@latest/rest/reference/actions#list-jobs-for-a-workflow-run
max_jobs=100

status_url = "https://api.github.com/repos/" \
         + os.environ['GITHUB_REPOSITORY'] \
         + "/actions/runs/" \
         + os.environ['GITHUB_RUN_ID'] \
         + "/jobs" \
         + "?per_page=" + str(max_jobs)

numOfJobs = int(os.environ['NUM_OF_JOBS'])


if(numOfJobs > max_jobs):
  sys.exit("ERROR: number of jobs exceeded max_jobs: " + str(max_jobs))

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

