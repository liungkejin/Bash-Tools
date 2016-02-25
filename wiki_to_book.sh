#!/bin/bash

#
# Author: Kejin
# Date  : 2016/02/24
# EMail : liungkejin@foxmail.com
#

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

# 记录一组标题的缩进数据 [num_indent]="level:path";
declare -a title_indent_info=();
# 记录上一行信息 (num_line is_title num_indent content)
# declare -a last_line_info=();

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

# 处理标题等级
function process_ref_title()
{
    local
}

# 处理标题
declare -a last_title_info=();
declare -a cur_title_info=();
function process_title()
{
    cur_title_info=();

    local title="$1" num_indent="$2";
    title="$(tr -d [:punct:] <<<"$title")";
    # local i=0 ref_flag=0 char="" length=${#title};
    # for ((i=0; i<length; ++i)); then
    #     char="${title:$i:2}";
    #
    #     if ((ref_flag == 0)); then
    #         if [[ "$char" == "[[" ]]; then
    #             ((ref_flag==1));
    #         fi;
    #     fi;
    # done;

    local level=0 arr_size="${#title_indent_info[@]}";
    local last_same="${title_indent_info[$num_indent]}";

    local last_level=0 last_path="" title_path="";
    if [[ -n "$last_same" ]]; then
        last_level="${last_same%%:*}";
        last_path="${last_same#*:}";

        title_path="${last_path%\/*}/${title}";
        ((level=last_level));
    else if [[ -n "${last_title_info[@]}" ]]; then
        last_level="${last_title_info[1]}";
        last_path="${last_title_info[2]}";

        title_path="${last_path%\/*}/${title}";
        ((level=last_level+1));
    fi;

    title_indent_info[$num_indent]="${level}:${title_path}";
    cur_title_info=("${level}" "${num_indent}" "${title_path}");

    last_path="${out_dir}/$last_path";
    title_path="${out_dir}/$title_path";

    if [[ ! -d "$last_path" ]]; then
        :; # TODO
    fi;
}

# 处理 [[]] 里面引用的内容
# 凡是没有找到同等级的标题, 如果存在上一个标题，那就是上一个标题的子标题
declare -g result_return="";
declare -g alias_name_return="";
declare -g file_name_return="";
function process_ref_name()
{
    result_return="";
    alias_name_return="";
    file_path_return="";

    local ref_name="$1";

    local page_name="${ref_name#*|}";
    local alias_name="${ref_name%|$page_name}";

    local fname="$(get_file "$page_name")";

    if [[ -z "$fname" ]]; then
        echo -n " $ref_name ";
        return;
    fi;

    local src_file="${home_dir}/${fname}" out_file="${out_dir}/${fname}";
    cp "${src_file}" "${out_file}" || return;

    file_name_return="$fname";
    alias_name_return="$alias_name";
    result_return="[${alias_name}]($fname)";
}

# 处理包含 [[]] 的行
# 解析出两个数据
#  1. 判断是不是一个标题, 如果是的话, 他的空格是多少个
#  2. 找出 [[]] 里面的内容
declare -a last_title_out_files=();
declare -a cur_title_out_files=();
function process_line()
{
    cur_title_out_files=();

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

                process_title "${line:$((i+2)):$((length-i-2))}" "$num_indent";

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
                process_ref_name "$ref_name";
                result="${result}${result_return}";

                if ((is_title == 1)); then
                    [[ -n "${file_name_return}" ]] && cur_title_out_files[${#cur_title_out_files[@]}]="${file_name_return}";
                fi;

                ((i+=2));
                continue;
            fi;

            ref_name="${ref_name}${char}";

            ((i+=1));
            continue;
        fi;

        ((is_title == 1)) && title="${title}${char}";

        result="${result}${char}";
        ((i+=1));
    done;

    if ((is_title == 1)); then
        process_ref_title ;

        last_title_info=("${cur_title_info[@]}");
        last_title_out_files=("${cur_title_out_files[@]}");
    fi;

    echo "$result";
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
    TEMP_FILE="${out_dir}/${TEMP_FILE}";

    home_dir="${home_md%\/*}";
    if [[ -z "$home_dir" || "$home_dir" = "$home_md" ]]; then
        home_dir=".";
    fi;

    IFS=''; # 为了读取空格
    local num_line=0;
    while read line; do
        ((num_line += 1));
        process_line "$line" "$num_line";
    done< <(sed -e "s/\t/    /g" "$home_md");
}

main "$@"
