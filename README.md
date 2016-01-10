# BashTools
一些 Ubuntu 操作系统下的 Bash Shell 工具脚本

## install_jdk.sh (JDK 安装工具)

## Usage
```
sudo ./install_java.sh <jdk.XXX.tar.gz>
./install_java.sh <jdk.XXX.tar.gz>

如果以 root 权限运行 包括sudo, 则会将 java 安装在 /usr/lib/Java/jdkXXX 目录下
并将 JAVA_HOME, JRE_HOME, CLASSPATH, PATH 环境变量设置在 /etc/profile 中

如果以 普通用户权限运行, 则会将 java 安装在 ~/.Java/jdkXXX 目录下
并将 JAVA_HOME, JRE_HOME, CLASSPATH, PATH 环境变量设置在 ~/.bashrc 中

当脚本运行完成后, 需要重新启动一次系统, 保证环境变量设置正确
```

