# litex-conda-ci

Travis scripts for Litex-Hub/litex-conda-(compilers|eda|misc|prog) .

This repository is not meant to be used on its own, but as submodule for above repositories.

## Setting up Travis for your own fork

To use any of the litex-conda-* repositories in your own fork with Travis you must meet the following requirements:

* enable Travis for your repository
* create an account on https://anaconda.org/
* create an access token on https://anaconda.org/{your-account}/settings/access
* visit https://travis-ci.com/github/{your-account}/litex-conda-{suffix}/settings
* add two environment variables:
  * `ANACONDA_USER` - set to your anaconda username
  * `ANACONDA_TOKEN` - set to the value of the token you created
* remember to **disable** the `Display value in build log` option for `ANACONDA_TOKEN`
* create a daily or weekly Cron Job on the same settings page, to start on the master branch
  * this will ensure removal of temporary labels on your Anaconda account (they are created during the build)
