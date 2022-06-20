from pathlib import Path
from json import loads as json_loads

ROOT = Path(__file__).resolve().parent

# -- General configuration ---------------------------------------------------------------------------------------------

extensions = [
    "sphinx.ext.extlinks",
    "sphinx.ext.intersphinx",
]

source_suffix = {
    ".rst": "restructuredtext",
}

master_doc = "index"
project = "Conda recipes for FPGA EDA tools"
copyright = "2019-2022, hdl/conda-* contributors"
author = "hdl/conda-* contributors"

version = "latest"
release = version  # The full version, including alpha/beta/rc tags.

language = None

exclude_patterns = [
    "_build",
    "_theme",
]

numfig = True

# -- Options for HTML output -------------------------------------------------------------------------------------------

html_context = {}
ctx = ROOT / "context.json"
if ctx.is_file():
    html_context.update(json_loads(ctx.open("r").read()))

if (ROOT / "_theme").is_dir():
    html_theme_path = ["."]
    html_theme = "_theme"
    html_theme_options = {
        "logo_only": True,
        "home_breadcrumbs": False,
        "vcs_pageview_mode": "blob",
    }
    html_css_files = [
        "theme_overrides.css",
    ]
else:
    html_theme = "alabaster"

html_static_path = ["_static"]

html_logo = str(Path(html_static_path[0]) / 'logo.png')
html_favicon = str(Path(html_static_path[0]) / 'logo.png')

htmlhelp_basename = "CondaEDA"

# -- Options for LaTeX output ------------------------------------------------------------------------------------------

latex_elements = {
    "papersize": "a4paper",
}

latex_documents = [
    (
        master_doc,
        "CondaEDA.tex",
        "Conda recipes for FPGA EDA tools",
        author,
        "manual",
    ),
]

# -- Options for manual page output ------------------------------------------------------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (
        master_doc,
        "CondaEDA",
        "Conda recipes for FPGA EDA tools",
        [author],
        1,
    )
]

# -- Options for Texinfo output ----------------------------------------------------------------------------------------

texinfo_documents = [
    (
        master_doc,
        "CondaEDA",
        "Conda recipes for FPGA EDA tools",
        author,
        "EDA",
        "HDL verification.",
        "Miscellaneous",
    ),
]

# -- Sphinx.Ext.InterSphinx --------------------------------------------------------------------------------------------

intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "constraints": ("https://hdl.github.io/constraints", None)
}

# -- Sphinx.Ext.ExtLinks -----------------------------------------------------------------------------------------------

extlinks = {
    "wikipedia": ("https://en.wikipedia.org/wiki/%s", None),
    "awesome": ("https://hdl.github.io/awesome/items/%s", ""),
    "gh": ("https://github.com/%s", "gh:"),
    "ghsharp": ("https://github.com/hdl/conda-eda/issues/%s", "#"),
    "ghissue": ("https://github.com/hdl/conda-eda/issues/%s", "issue #"),
    "ghpull": ("https://github.com/hdl/conda-eda/pull/%s", "pull request #"),
    "ghsrc": ("https://github.com/hdl/conda-eda/blob/main/%s", ""),
}
