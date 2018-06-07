output_dir = not_set

abs_output_dir = $(abspath ${output_dir})
real_curdir = $(realpath ${CURDIR})

ifneq ($(findstring info,${MAKECMDGOALS}),)
$(info abs_output_dir: ${abs_output_dir} real_curdir: ${real_curdir} CURDIR: ${CURDIR})
endif

export_build = ${CURDIR}/src/scripts/export.sh -o ${abs_output_dir} -s ${real_curdir}
export_clean = ${CURDIR}/src/scripts/export.sh -o ${abs_output_dir} -s ${real_curdir} -C

.PHONY: all clean info

all:
	@${CURDIR}/src/scripts/generate_html.sh -w ${CURDIR}
	@[ x"${output_dir}" != x"not_set" ] && { mkdir -p ${abs_output_dir} && ${export_build}; } || true

clean:
	@${CURDIR}/src/scripts/generate_html.sh -c -w ${CURDIR}
	@[ x"${output_dir}" != x"not_set" ] && ${export_clean} || true

info:
	@true
