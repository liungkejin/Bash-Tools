#!/bin/bash

# 记性太差了, 每次安装 Java 都得搜一次教程, 烦死了, 所以写个自动脚本

#
# Author: Kejin
# Date:   2016/01/10
# Email:  liungkejin@foxmail.com
#

TempDir="/tmp/tempJavaDir_$((RANDOM * 100))";
if [[ -e $TempDir ]]; then
	rm -rf $TempDir/*;
fi;

JavaTarFile="${1}";

JavaDestDir="${HOME}/.Java";

InitProfile="${HOME}/.bashrc";

if (( $UID == 0 )); then
	JavaDestDir="/usr/lib/Java";
	InitProfile="/etc/profile";
fi;

InitProfileBackup="${InitProfile}_backup";

FUNC_MAIN="
error()
{
	echo $@ >&2;

	rm -rf $TempDir;
	exit -1;
};

main()
{
	if (( $# != 1 )); then
		error 'Usage: ${0} <jdk-xxx-linux-xxx.tar.gz>';
	elif [[ ! -e ${JavaTarFile} ]]; then
		error ${JavaTarFile} ' is not exist!';
	fi;

	if [[ ! -e $JavaDestDir ]]; then
		mkdir -p $JavaDestDir;
	fi;

	if [[ ! -d $JavaDestDir ]]; then
		error $JavaDestDir ' is not exist Or not a directory!';
	fi;

	echo 'Extracting $JavaTarFile To $TempDir';
	if mkdir -p $TempDir && tar zxf ${JavaTarFile} --directory=$TempDir; then
		echo 'Extract Finished!';
		echo;

		JavaName=\"\$(ls $TempDir)\";
		JavaTemp=\"$TempDir/\$JavaName\";
		JavaHome=\"$JavaDestDir/\$JavaName\";
		echo \$JavaName;
		echo \$JavaTemp;
		echo \$JavaHome;

		echo \"Copy \$JavaTemp To \$JavaHome\";

		cp -R ${TempDir}/* ${JavaDestDir};
		echo 'Copy Finished!';
		echo;

		echo 'Write Env Variable JAVA_HOME, JRE_HOME, CLASSPATH, PATH to $InitProfile';
		cp $InitProfile $InitProfileBackup;

		echo '################## Add For Java ##################' >> $InitProfile;
		echo \"export JAVA_HOME=\${JavaHome}\" >> $InitProfile;
		echo \"export JRE_HOME=\\\${JAVA_HOME}/jre\" >> $InitProfile;
		echo \"export CLASSPATH=\\\${JAVA_HOME}/lib:\\\${JRE_HOME}/lib\" >> $InitProfile;
		echo \"export PATH=\${PATH}:\\\${JAVA_HOME}/bin\" >> $InitProfile;
		echo '##################     End      ##################' >> $InitProfile;

		. $InitProfile;
	
		if java -version; then
			echo 'install java successfully';
		else 
			cp $InitProfileBackup $InitProfile;
			error 'install java failed';
		fi;
	else
		error 'Extract Tar File Failed!';
	fi;

	rm -rf $TempDir;
}";

if (( $UID == 0 )); then
	#不知道为啥, 只有真正成为了root才能写 /etc/profile 成功
	su root -c "$FUNC_MAIN; main $@; exit;";

	. $InitProfile;
else
	eval "$FUNC_MAIN";
	main $@;
fi;

echo;
echo "JAVA_HOME=${JAVA_HOME}";
echo "JRE_HOME=${JRE_HOME}";
echo "CLASSPATH=${CLASSPATH}";
echo "PATH=${PATH}";
echo;

echo -e "\033[31m Reboot system for complete install...\033[0m";
