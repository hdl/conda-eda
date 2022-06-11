#!/usr/bin/env python3

from pathlib import Path
from sys import exit as sys_exit
from os import environ
from subprocess import check_call
from urllib.request import urlopen
from json import loads as json_loads

# We're limited to this number by GH Actions API
# https://docs.github.com/en/free-pro-team@latest/rest/reference/actions#list-jobs-for-a-workflow-run
max_jobs = 100

status_url = "https://api.github.com/repos/" \
         + environ['GITHUB_REPOSITORY'] \
         + "/actions/runs/" \
         + environ['GITHUB_RUN_ID'] \
         + "/jobs" \
         + "?per_page=" + str(max_jobs)

numOfJobs = int(environ.get('NUM_OF_JOBS', 0))

if(numOfJobs > max_jobs):
  sys_exit("ERROR: number of jobs exceeded max_jobs: " + str(max_jobs))

# Check if all jobs succeeded
jobFailure = False
with urlopen(status_url) as url:
  data = json_loads(url.read().decode())
  for j in data["jobs"]:
    # THIS is master-package job, still in progress (not concluded)
    if(j["conclusion"] != "success" and j["name"] != "master-package"):
      jobFailure = True
      break

scripts_dir = Path(environ['CI_SCRIPTS_PATH'])

if environ.get('GITHUB_REF', '') == 'refs/heads/master':
  check_call(scripts_dir / "master-package.sh")

check_call(scripts_dir / "cleanup-anaconda.sh")
