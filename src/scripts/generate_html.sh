#!/bin/bash

# ${1}: webpage base dir location

[ x"${1}" != x ] || { echo "no src directory specified"; exit 1; }
[ -d "${1}" ] || { echo "'${1}' is not a directory"; exit 1; }
[ -f "${1}"/.webpage ] || { echo "'${1}' is not a webpage directory"; exit 1; }

webpage_dir="${1}"
srcdir="${webpage_dir}"/src

languages=$(for language_file in "${srcdir}"/text/*.txt; do basename ${language_file} .txt; done)

tmpdir=$(mktemp -d)
for language in ${languages}; do

    printf "generating '%s' language html files\n" "${language}"

    language_file="${srcdir}"/text/${language}.txt
    subst_tags=$(cut -d= -f1 ${language_file})
    src_html_files="${srcdir}"/html/*.html
    outdir="${webpage_dir}"/html/${language}

    mkdir -p ${outdir}
    source "${language_file}"

    for src_html_file in ${src_html_files}; do

        html_filename="$(basename ${src_html_file})"
        html_file="${webpage_dir}"/html/${language}/"${html_filename}"
        tmpfile=${tmpdir}/${language}-"${html_filename}"

        printf "generating '%s' in '%s' language\n" "${html_file}" "${language}"

        cp ${src_html_file} ${tmpfile}
        for subst_tag in ${subst_tags}; do
            subst_text="$(eval echo \${${subst_tag}})"
            printf "substituting '%s' for '%s'\n" "${subst_tag}" "${subst_text}"
            sed -e "s/\[${subst_tag}\]/${subst_text}/" ${tmpfile} > ${tmpfile}.1
            mv ${tmpfile}.1 ${tmpfile}
        done
        mv ${tmpfile} ${html_file}

    done

done

exit 0
