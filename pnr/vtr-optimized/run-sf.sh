# Run VPR on an example .eblif to collect PGO data

pushd ${BUILD_ROOT}/symbiflow

# Runs the following command, printing only lines starting
# with '#' unless the command fails, in which case it will
# print the entire log.
quiet() {
    ("$@" | tee full.log | grep -e '^#') || cat full.log
}

# Parameters
NET=ibex_arty
DEVICE=xc7a50t_test
PART=xc7a35tcsg324-1
EBLIF=benchmarks/circuits/${NET}.eblif
SDC=benchmarks/sdc/${NET}.sdc
PLACE_CONSTRAINTS=benchmarks/place_constr/${NET}.place
PATH=${BUILD_ROOT}/build/vpr:${BUILD_ROOT}/build/utils/fasm:${BUILD_ROOT}/symbiflow/bin:${PATH}

# Pack
quiet symbiflow_pack -e ${EBLIF} -d ${DEVICE} -s ${SDC}

# Place
# This should be:
#
#     quiet symbiflow_place -e ${EBLIF} -d ${DEVICE} -n ${NET}.net -P ${PART} -s ${SDC}
#
# Currently, using this command results in:
#
#     Traceback (most recent call last):
#       File ".../symbiflow/share/symbiflow/scripts/prjxray_create_ioplace.py", line 178, in <module>
#         main()
#       File ".../symbiflow/share/symbiflow/scripts/prjxray_create_ioplace.py", line 169, in main
#         io_place.output_io_place(args.output)
#       File ".../symbiflow/share/symbiflow/scripts/vpr_io_place.py", line 151, in output_io_place
#         max_name_length = max(len(c.name) for c in self.constraints.values())
#     ValueError: max() arg is an empty sequence
#
# The following lines are needed to override the placement constraints
# with those that were downloaded instead of the generated ones.
(
    export MYPATH=${BUILD_ROOT}/symbiflow/bin
    source bin/vpr_common
    parse_args -e ${EBLIF} -d ${DEVICE} -n ${NET}.net -P ${PART} -s ${SDC}
    quiet run_vpr --fix_clusters ${PLACE_CONSTRAINTS} --place
)

# Route
quiet symbiflow_route -e ${EBLIF} -d ${DEVICE} -s ${SDC}

# Write FASM
quiet symbiflow_write_fasm -e ${EBLIF} -d ${DEVICE} -s ${SDC}

popd
