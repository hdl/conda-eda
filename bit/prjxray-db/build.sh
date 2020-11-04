#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

DEVICES="artix7 kintex7 zynq7"
DBDIR="${PREFIX}/share/symbiflow/prjxray-db"

mkdir -p $DBDIR

for device in $DEVICES; do
    cp -r $device $DBDIR
done

mkdir -p $PREFIX/bin

DB_CONFIG="${PREFIX}/bin/prjxray-config"

echo -e "#!/bin/bash\n\necho ${DBDIR}" > ${DB_CONFIG}
chmod +x ${DB_CONFIG}
