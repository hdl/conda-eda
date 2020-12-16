# Run VPR on an example .eblif to collect PGO data

pushd ${BUILD_ROOT}/symbiflow

# Runs the following command, printing only lines starting
# with '#' unless the command fails, in which case it will
# print the entire log.
quiet() {
    ("$@" | tee full.log | grep -e '^#') || cat full.log
}

# Parameters
CIRCUIT=minilitex_ddr_arty
DEVICE=xc7a50t_test
PART=xc7a35tcsg324-1
EBLIF=benchmarks/circuits/${CIRCUIT}.eblif
SDC=benchmarks/sdc/${CIRCUIT}.sdc
PLACE_CONSTRAINTS=benchmarks/place_constr/${CIRCUIT}.place
NET=${CIRCUIT}.net
PATH=${BUILD_ROOT}/build/vpr:${BUILD_ROOT}/build/utils/fasm:${BUILD_ROOT}/symbiflow/bin:${PATH}

# Pack
quiet symbiflow_pack -e ${EBLIF} -d ${DEVICE} -s ${SDC}

# Place
cp ${PLACE_CONSTRAINTS} .
quiet symbiflow_place -e ${EBLIF} -d ${DEVICE} -n ${NET} -P ${PART} -s ${SDC}

# Route
quiet symbiflow_route -e ${EBLIF} -d ${DEVICE} -s ${SDC}

# Write FASM
quiet symbiflow_write_fasm -e ${EBLIF} -d ${DEVICE} -s ${SDC}

popd
