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
为了将一个 git 项目的 wiki 进行翻译并 push 到 gitbook 上方便阅读和分享，
这个工具就是为了将 wiki 的目录(Home.md) 转换为 gitbook 的目录(SUMMARY.md)，
同时也会根据 wiki 每个目录项目的等级，将对应的页面放入到同等级的目录下，方便管理

$ ./wiki_to_book.sh <Path of Home.md> <Path of SUMMARY.md>

注意在 wiki 的主目录运行
```
