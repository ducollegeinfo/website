#!/bin/bash

version="1.0.0"

type id &>/dev/null || { printf "'%s' required but not found in PATH\n" id 1>&2; exit 1; }
me=$(id -un)
utils=${HOME}/lib/bash_utils
[ -e ${utils} ] && . ${utils} || { printf "clone and setup env git repo for ${me}!\n" 1>&2 ; exit 1; }

output_dir=""
src_dir=""
clean="n"

optstr="o:s:C"
usage_opt_str="-o <webpage dir> [-c]"
handle_opts() {
    case ${opt} in
        o) output_dir="${OPTARG}"; return 0;;
        s) src_dir="${OPTARG}"; return 0;;
        C) clean="y"; return 0;;
    esac
    return 1
}

get_opts $@

[ x"${output_dir}" != x ] || { exit 1; }
[ x"${src_dir}" != x ] || { exit 1; }

[ -d "${output_dir}" ] || { exit 1; }
[ -d "${src_dir}" ] || { exit 1; }

output_dir="$(realpath ${output_dir})"
src_dir="$(realpath ${src_dir})"

[ "${output_dir}" != "${src_dir}" ] || { exit 1; }

if [ ${clean} = y ]; then
    [ -f ${output_dir}/.webpage ] || { exit 1; }
    printf "removing '%s' exported directory\n" "${output_dir}"
    rm -rf ${output_dir}
    exit 0
fi

printf "exporting to '%s' directory\n" "${output_dir}"
cp -R "${src_dir}"/* "${output_dir}"
cp .webpage "${output_dir}"
exit 0
