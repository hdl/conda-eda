# Run VPR on an example .eblif to collect PGO data

pushd ${BUILD_ROOT}/symbiflow

EBLIF=benchmarks/circuits/ibex_arty.eblif
SDC=benchmarks/sdc/ibex_arty.sdc
PATH=${BUILD_ROOT}/build/vpr:${BUILD_ROOT}/build/utils/fasm:${BUILD_ROOT}/symbiflow/bin:${PATH}

xz --decompress ${EBLIF}.xz
symbiflow_pack -e ${EBLIF} -d xc7a50t_test -s ${SDC}
symbiflow_place -e ${EBLIF} -d xc7a50t_test -n top.net -P xc7a35tcsg324-1 -s ${SDC}
symbiflow_route -e ${EBLIF} -d xc7a50t_test -s ${SDC}
symbiflow_write_fasm -e ${EBLIF} -d xc7a50t_test -s ${SDC}

popd
