#!/bin/bash

version="1.0.0"

type id &>/dev/null || { printf "'%s' required but not found in PATH\n" id 1>&2; exit 1; }
me=$(id -un)
utils=${HOME}/lib/bash_utils
[ -e ${utils} ] && . ${utils} || { printf "clone and setup env git repo for ${me}!\n" 1>&2 ; exit 1; }

webpage_dir=""
clean="n"

optstr="w:c"
usage_opt_str="-w <webpage dir> [-c]"
handle_opts() {
    case ${opt} in
        w) webpage_dir="${OPTARG}"; return 0;;
        c) clean="y"; return 0;;
    esac
    return 1
}

get_opts $@

[ x"${webpage_dir}" != x ] || { echo "no src directory specified"; exit 1; }
[ -d "${webpage_dir}" ] || { echo "'${webpage_dir}' is not a directory"; exit 1; }
[ -f "${webpage_dir}"/.webpage ] || { echo "'${webpage_dir}' is not a webpage directory"; exit 1; }

srcdir="${webpage_dir}"/src

languages=$(for language_file in "${srcdir}"/text/*.txt; do basename ${language_file} .txt; done)

tmpdir=$(mktemp -d)
for language in ${languages}; do

    [ ${clean} = y ] && action="removing" || action="generating"
    printf "%s '%s' language html files\n" "${action}" "${language}"

    language_file="${srcdir}"/text/${language}.txt
    subst_tags=$(cut -d= -f1 ${language_file})
    src_html_files="${srcdir}"/html/*.html
    outdir="${webpage_dir}"/html/${language}

    mkdir -p ${outdir}
    source "${language_file}"

    for src_html_file in ${src_html_files}; do

        src_html_filename=$(basename ${src_html_file})
        tmpfile=${tmpdir}/${language}-"${src_html_filename}"

        # get filename for a language from the source file if present, else
        # keep the source name
        html_filename=$(grep -E "^${language}=" ${src_html_file} | cut -d= -f2)
        [ x${html_filename} = x ] && html_filename=${src_html_filename}

        html_file="${webpage_dir}"/html/${language}/"${html_filename}"

        if [ ${clean} = y ]; then
            printf "removing generated file '%s'\n" "${html_file}"
            rm -f "${html_file}"
            continue
        fi

        cp ${src_html_file} ${tmpfile}

        # remove two-letter language lines from html file
        sed -e '/^[a-z][a-z]=/d' ${src_html_file} > ${tmpfile}

        printf "generating '%s' in '%s' language\n" "${html_file}" "${language}"

        for subst_tag in ${subst_tags}; do
            subst_text="$(eval echo \${${subst_tag}})"
            printf "substituting '%s' by '%s'\n" "${subst_tag}" "${subst_text}"
            sed -e "s|\[${subst_tag}\]|${subst_text}|g" ${tmpfile} > ${tmpfile}.1
            mv ${tmpfile}.1 ${tmpfile}
        done
        mv ${tmpfile} ${html_file}

    done

done

exit 0
