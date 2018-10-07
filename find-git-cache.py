from __future__ import print_function

import contextlib
import io
import os

from conda_build import source
from conda_build.config import get_or_merge_config
from conda_build.metadata import MetaData
from conda_build.variants import get_package_variants, set_language_env_vars


def mirror_dir(package, metadata, data_type=None):
    name, _ = (package+'/').split('/', 1)

    sources = metadata.get_section('source')
    if isinstance(sources, list):
        meta = [x for x in sources if x['folder'] == name][0]
    else:
        meta = sources

    if not data_type:
        return meta

    if data_type == 'git_url':
        git_url = meta['git_url']
        git_dn = git_url.split('://')[-1].replace('/', os.sep)
        if git_dn.startswith(os.sep):
            git_dn = git_dn[1:]
        git_dn = git_dn.replace(':', '_')
        return os.path.join(metadata.config.git_cache, git_dn)
    else:
        return meta[data_type]


def main(recipe_dir=None, data_type=None, variant=None):
    # Get the extra_source section of the metadata.
    if recipe_dir is None:
        recipe_dir = os.environ["RECIPE_DIR"]
    assert recipe_dir is not None, recipe_dir

    if variant:
        extra = {'variant_config_files': '%s/conda_build_config.%s.yaml' % (recipe_dir, variant)}
    else:
        extra = {}

    f = io.StringIO()
    with contextlib.redirect_stdout(f):
        config = get_or_merge_config(None, **extra)
        variants = get_package_variants(recipe_dir, config)
    assert len(variants) == 1
    metadata = MetaData(recipe_dir, config=config, variant=variants[0])
    try:
        print(mirror_dir(recipe_dir, metadata, data_type))
    except KeyError:
        pass


if __name__ == "__main__":
    import sys
    f = io.StringIO()
    with contextlib.redirect_stderr(f):
        main(*sys.argv[1:])
