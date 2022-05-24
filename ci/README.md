# conda-ci

GitHub Actions scripts for hdl/conda-(compilers|eda|misc|prog) .

This repository is not meant to be used on its own, but as submodule for above repositories.

## Setting up Github Actions for your own fork

To use any of the conda-* repositories in Github Actions you must meet the following requirements:

* create an account on https://anaconda.org/
* create an access token on https://anaconda.org/{your-account}/settings/access
* follow https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-an-environment to add two encrypted secrets:
  * `ANACONDA_USER` - set to your anaconda username
  * `ANACONDA_TOKEN` - set to the value of the token you created
