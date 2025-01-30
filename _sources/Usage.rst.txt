.. _Usage:

Usage
#####

Find what conda is, what it does and how to use it in the :doc:`conda:user-guide/index` at `conda.io <https://conda.io>`__.

.. _Usage:Bumping:

Bumping/overriding specific tools
=================================

Since several of the tools provided through ``hdl/conda-*`` repositories are rapidly evolving projects, users,
contributors or developers might need to tweak the environments.
This section explains various strategies to do so.

* Report the issue upstream.
  ``hdl/conda-*`` repositories build the latest main branches of upstreams.
  Therefore, the best approach to have a bug fixed or an additional feature is to report an issue upstream.

* A developer or a contributor might eventually create a feature branch with the fix/enhancement.
  There are various solutions to build a variant of a package/tool from a feature branch.
  See :ref:`Usage:Bumping:Package`, :ref:`Usage:Bumping:Manual` and/or :ref:`Usage:Bumping:Outside`.

* After the fix/enhancement is pushed to the main branch upstream, it should be built in the corresponding ``hdl/conda-*``
  repository within 24h.
  Hence, it is recommended to wait until that is done before bumping the Conda packages downstream.

  * If the CI job fails, report it in the corresponding ``hdl/conda-*`` repository.

* Update/bump the tool in the downstream Conda ``environment.yml`` file, or in the sibling ``conda_lock.yml``.

* Update/recreate the Conda environment.


.. _Usage:Bumping:Channel:

Using a different Conda channel
-------------------------------

Mixing packages from multiple channels (e.g. ``conda-forge`` and ``defaults``) is possible.
However, it might produce library mismatches preventing the environment from being bootstraped.


.. _Usage:Bumping:Package:

Building Conda packages youself
-------------------------------

Build the conda package yourself.
In order to push it somewhere, Conda credentials are required.
Hence, it can be cumbersome and it's recommended to instead wait for CI in the ``hdl/conda-*`` repos to run.


.. _Usage:Bumping:Manual:

Building tools manually inside Conda
------------------------------------

*TBC*

Yosys SystemVerilog plugin
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. Warning::
   The expected usage of the plugin by using the ``read_systemverilog`` command (used by default in F4PGA flow) should work.
   When using the plugin by calling ``read_uhdm`` command, take additional care to use the same Surelog and UHDM version for creating and reading the UHDM file - updating only the plugin can create a mismatch in this case.

Make sure ``curl``, ``jq``, ``tar`` and ``wget`` are installed (used to automatically download newest version):

.. code-block:: bash
   :name: get-utils

   apt install curl jq tar wget

Activate the conda repository for the correct family:

.. code-block:: bash
   :name: activate-xc7

   conda activate xc7

Obtain the latest release of the plugin from `here <https://github.com/antmicro/yosys-uhdm-plugin-integration/releases>`_:

.. code-block:: bash
   :name: get-plugin

   curl https://api.github.com/repos/antmicro/yosys-uhdm-plugin-integration/releases/latest | jq .assets[1] | grep "browser_download_url" | grep -Eo 'https://[^\"]*' | xargs wget -O - | tar -xz

Install the plugin using provided installation script.
It will use the ``yosys-config`` from conda, so it will install into the conda environment.

.. code-block:: bash
   :name: install-plugin

   ./install-plugin.sh


.. _Usage:Bumping:Outside:

Building/installing tools outside of Conda
------------------------------------------

For development/testing purposes, tools can be optionally built outside of Conda and prepended to the ``PATH`` so
they are found first.
However, problems related to mismatching system libraries might be expected.
It is strongly recommended to build tools statically if this approach is to be followed.
