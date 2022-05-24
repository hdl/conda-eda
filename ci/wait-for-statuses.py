import urllib.request
import json
import subprocess
import time
import os
import sys

# We're limited to this number by GH Actions API
# https://docs.github.com/en/free-pro-team@latest/rest/reference/actions#list-jobs-for-a-workflow-run
max_jobs = 100

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

  print("Completed jobs: " + str(countCompleted) + ". Jobs overall: " + str(numOfJobs))
  if(countCompleted >= numOfJobs):
    break

# Check if all jobs succeeded
jobFailure = False
with urllib.request.urlopen(status_url) as url:
  data = json.loads(url.read().decode())
  for j in data["jobs"]:
    # THIS is master-package job, still in progress (not concluded)
    if(j["conclusion"] != "success" and j["name"] != "master-package"):
      jobFailure = True
      break

scripts_dir = os.environ['CI_SCRIPTS_PATH']

branch = os.environ.get('GITHUB_REF', '')
# Upload packages only when whole build succeeded
# and we are on master branch
if(branch == 'refs/heads/master'):
  if(not jobFailure):
    subprocess.call(os.path.join(scripts_dir, "master-package.sh"))
else:
  print("Not on master branch, don't execute master-package.sh. Current branch: " + str(branch))

# Always clean up
subprocess.call(os.path.join(scripts_dir, "cleanup-anaconda.sh"))

if(jobFailure):
  sys.exit("ERROR: some jobs failed")
