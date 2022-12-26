#!/bin/bash

set -e
set -x

# Identify OS
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac

make V=1 CMAKE_PARAMS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DVTR_IPO_BUILD=off" -j$CPU_COUNT
if [[ $OS != "Mac" ]]; then
	make test
fi
make install

mkdir -p ${PREFIX}/lib
mv ${PREFIX}/bin/*.a ${PREFIX}/lib/

CAPNP_SCHEMAS=${PREFIX}/bin/capnp-schemas-dir

echo -e "#!/bin/bash\n\necho ${PREFIX}/capnp" > ${CAPNP_SCHEMAS}
chmod +x ${CAPNP_SCHEMAS}
