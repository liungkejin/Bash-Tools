#!/bin/bash

#
# 此脚本的目的是为了将 github Wiki 页面转换为 gitbook
# 即将 Home.md 转换为 SUMMARY.md, 并将相应的文件转入到相应等级的文件夹下,
# 注意：
#   只有使用了 github 默认的 wiki 目录方式 [[New Page]] 才会被转换
#
# 例如：wiki 的目录结构如下:
#  /Home.md
#  /Page1.md
#  /Page2.md
#  /Page3.md
#
#  Home.md 里的目录结构如下:
#     * Introduction
#        * [[Page1]]
#     * [[Getting Start | Page2 ]]
#        * [[Page3]]
#
# 最终输出的目录结构为:
#  /SUMMARY.md
#  /Introduction
#       /Page1.md
#  /Getting-Start
#       /Page2.md
#       /Page3.md
#
# SUMMARY.md 里的目录结构如下:(会把特殊字符过滤掉)
#   * Introduction
#       * [Page1](Introduction/Page1.md)
#   * [Getting Start](Getting-Start/Page2.md)
#       * [Page3](Getting-Start/Page3.md)
#

#
# Usage:
#   $ ./wiki_to_book.sh  # 默认 Home.md 和 目标目录 都在当前文件夹下 wiki_to_book_output 下
#   $ ./wiki_to_book.sh <Path of Home.md> # 默认 目标目录 在当前文件夹下的 wiki_to_book_output 下
#   $ ./wiki_to_book.sh <Path of Home.md> <Path of Dest Directory>
#
#

#
# Author: Kejin
# Date  : 2016/02/24
# EMail : liungkejin@foxmail.com
#
FILE_SUFFIX=(
    "asciidoc"
    "textile"
    "md"
    "markdown"
    "mediawiki"
    "org"
    "pod"
    "rdoc"
    "creole"
    "rest");

DEF_HOME_MD="Home.md";
DEF_OUT_DIR="wiki_to_book_output";
TEMP_FILE=".LING_SHI_WEN_JIAN_MING_ZI_YAO_CHANG";

home_dir=".";
home_md=${DEF_HOME_MD};
out_dir=${DEF_OUT_DIR};

# 标示 index 是否存在
declare -a indent_flag=();
# 保存标题结构数据
declare -a title_struct=();
global_var="";

# 根据名字找到对应的文件
function get_file()
{
    local name="$1" tname="$(tr ' /' '-' <<< "$1")";
    local suf="" path="" tpath="";

    for suf in "${FILE_SUFFIX[@]}"; do
        path="${home_dir}/${name}.${suf}";
        tpath="${home_dir}/${tname}.${suf}";
        if [[ -e "$path" ]]; then
            echo -n "$name.${suf}";
            return;
        elif [[ -e "$tpath" ]]; then
            echo -n "$tname.${suf}";
            return;
        fi;
    done;
}

# 处理 [[]] 里面引用的内容
# 凡是没有找到同等级的标题, 如果存在上一个标题，那就是上一个标题的子标题
function process_ref_name()
{
    global_var="";

    local ref_name="$1" is_title="$2" num_indent="$3" num_line="$4";

    local page_name="${ref_name#*|}";
    local alias_name="${ref_name%|$page_name}";

    local fname="$(get_file "$page_name")";

    if [[ -z "$fname" ]]; then
        echo -n " $ref_name ";
        return;
    fi;

    local src_file="${home_dir}/${fname}" out_file="${out_dir}/${fname}";
    if ! cp "${src_file}" "${out_file}"; then
        return;
    fi;

    local flag=indent_flag[$num_indent]
    local size="${#}"
    if [[ -z "$flag" ]]; then
        :;
    fi;

    # 找到最后一个比当前的 indent 多的路径
    local t i=0 lev=0 indent=0 info="";
    local level=0 arr_size="${#title_struct[@]}";
    for ((i=arr_size-1; i >= 0; --i)); do
        info="${title_struct[$i]}";

        IFS=':';
        read lev indent t <<<"${info}";
        IFS='';

        local name="${info#*;}";
        local path="${out_dir}/${name}";
        local dir="${path%.*}";

        if ((num_indent < indent)); then
            ((level=lev+1));
            if [[ -d "${path}" ]]; then
                mv "${out_file}" "$path" && fname="${path}/${fname}";
            elif [[ -f "${path}" ]]; then
                if mkdir -p "$dir"; then
                    if mv "${path}" "$dir" && mv "${out_file}" "$dir"; then
                        fname="${dir}/${fname}";
                        title_struct[$i]="${lev}:${indent}:;${dir}";
                    fi;
                fi;
            fi;
            break;
        elif ((num_indent == indent)); then
            mv "${out_file}" "$dir";
            break;
        else
            :;
        fi;
    done;

    title_struct[${arr_size}]="${level}:${num_indent}:;${fname}";

    global_var="[${alias_name}]($fname)";
}

# 处理包含 [[]] 的行
# 解析出两个数据
#  1. 判断是不是一个标题, 如果是的话, 他的空格是多少个
#  2. 找出 [[]] 里面的内容
function process_line()
{
    local line="$1" num_line="$2" result="";
    local i=0 char="" wchar="" length=${#line};

    local ref_beg=0 ref_name="";
    local is_title=0 num_indent=0 title="";

    while ((i < length)); do
        char="${line:$i:1}";
        wchar="${line:$i:2}";

        if ((is_title == 0)); then
            if [[ "$wchar" = '* ' ]]; then
                ((is_title = 1));

                title="${line:$((i+2)):$((length-i-2))}";
                result="${result}${wchar}";
                ((i+=2));
                continue;

            elif [[ "$char" = ' ' ]]; then
                ((num_indent += 1));
            else
                ((is_title = 2));
            fi;
        fi;

        if ((ref_beg == 0)); then
            if [[ "${wchar}" = "[[" ]]; then
                ((ref_beg = 1));

                ((i+=2));
                continue;
            fi;
        elif ((ref_beg == 1)); then
            if [[ "${wchar}" = "]]" ]]; then
                ((ref_beg = 0));
                process_ref_name "$ref_name" "$is_title" "$num_indent" "$num_line";
                result="${result}${global_var}";
                ((i+=2));
                continue;
            fi;

            ref_name="${ref_name}${char}";

            ((i+=1));
            continue;
        fi;

        result="${result}${char}";
        ((i+=1));
    done;

    echo "$result";
    # if ((is_title==1)); then
    #     if [[ -n "${ref_name}" ]]; then
    #         echo "${num_indent}, ${ref_name}";
    #     else
    #         echo "${num_indent}, ${title}";
    #     fi;
    #
    # else
    #     echo "not a title";
    # fi;
}

function main()
{
    if (($# > 2)); then
        echo -e "Usage: \n $0 \n $0 <Path of Home.md> \n $0 <Path of Home.md> <Path of dest dir> ";
        exit -1;
    fi;

    if (($# == 1)); then
        home_md="$1";
    elif (($# == 2)); then
        home_md="$1";
        out_dir="$2";
    fi;

    if [[ ! -e "$home_md" ]]; then
        echo "$home_md not exists!" >&2;
        exit -1;
    fi;

    if ! mkdir -p "$out_dir"; then
        echo "create output dir '$out_dir' failed!";
        exit -1;
    fi;

    home_dir="${home_md%\/*}";
    if [[ -z "$home_dir" || "$home_dir" = "$home_md" ]]; then
        home_dir=".";
    fi;

    IFS=''; # 为了读取空格
    local num_line=0;
    while read line; do
        process_line "$line" "$num_line";
        ((num_line += 1));
    done< <(sed -e "s/\t/    /g" "$home_md");
}

main "$@"
