#!/bin/bash

#
# 此脚本的目的是为了将 github Wiki 页面转换为 gitbook
# 即将 Home.md 转换为 SUMMARY.md
#
# Usage:
#   WikiToBook.sh <Path of Home.md> <Path of SUMMARY.md>
# 如果没有参数就默认为当前目录下的 Home.md 和 SUMMARY.md
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

SUF_ASCIIDOC=("asciidoc");
SUF_TEXTILE=("textile");
SUF_MARKDOWN=("md" "markdown");

DEF_HOME_MD="Home.md"
DEF_SUMMARY_MD="SUMMARY.md";
TEMP_FILE=".LING_SHI_WEN_JIAN_MING_ZI_YAO_CHANG"

home_md=${DEF_HOME_MD};
summary_md=${DEF_SUMMARY_MD};

if (($# == 2)); then
    home_md="$1";
    summary_md="$2";
fi;

if [[ ! -e "$home_md" ]]; then
    echo "$home_md not exists!" >&2;
    exit -1;
fi;

# 将 tab 换成 4 个空格
sed -e "s/\t/    /g" "$home_md" > "$TEMP_FILE";

IFS=''; # 禁止忽略空格
while read line; do
    echo "$line";

done< <(cat $TEMP_FILE);
