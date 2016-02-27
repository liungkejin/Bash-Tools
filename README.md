# BashTools
一些有用的 Bash Shell 工具脚本

## install_jdk.sh (JDK 安装工具)

### Details
```bash
每次在 linux 上安装 Java 都得搜一遍教程, 索性写个脚本

$ sudo ./install_jdk.sh <jdk.XXX.tar.gz>
$ ./install_jdk.sh <jdk.XXX.tar.gz>

如果以 root 权限运行 包括sudo, 则会将 java 安装在 /usr/lib/Java/jdkXXX 目录下
并将 JAVA_HOME, JRE_HOME, CLASSPATH, PATH 环境变量设置在 /etc/profile 中

如果以 普通用户权限运行, 则会将 java 安装在 ~/.Java/jdkXXX 目录下
并将 JAVA_HOME, JRE_HOME, CLASSPATH, PATH 环境变量设置在 ~/.bashrc 中

当脚本运行完成后, 需要重新启动一次系统, 保证环境变量设置正确
```

## wiki_to_book.sh (将 git wiki 转换成 gitbook 的工具)
### Details
```bash
#
# 此脚本的目的是为了将 github Wiki 页面转换为 gitbook, 方便阅读和分享
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
#       /Page3.md
#  /Page2.md
#
# SUMMARY.md 里的目录结构如下:(会把特殊字符过滤掉)
#   * Introduction
#       * [Page1](Introduction/Page1.md)
#   * [Getting Start](Getting-Start/Page2.md)
#       * [Page3](Getting-Start/Page3.md)
#

$ ./wiki_to_book.sh
$ ./wiki_to_book.sh <Path of Home.md>
$ ./wiki_to_book.sh <Path of Home.md> <Path of SUMMARY.md>

```
