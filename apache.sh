#/bin/bash

# 变量
baseDir=$(pwd)

# 加载配置文件
source "${baseDir}/httpd.conf"  

# 引入函数库
. libs/func.sh

echo -e  "\033[33m+----------------------------------------------------------------------+\033[0m"
echo -e  "\033[33m|       Apache v1.0.0 for Centos Linux Server, Written by Licess       |\033[0m"
echo -e  "\033[33m+----------------------------------------------------------------------+\033[0m"
echo -e  "\033[33m+                         httpd 2.4                                    +\033[0m"
echo -e  "\033[33m+----------------------------------------------------------------------+\033[0m"
echo -e  "\033[33m+           A tool to auto-compile & install Apache on Linux           +\033[0m"
echo -e  "\033[33m+----------------------------------------------------------------------+\033[0m"

# 输入安装目录
echo "------------------------------------------------------------------------"
echo "------------------------------------------------------------------------"
echo -e "\033[33mPlease enter the installation directory。(default /usr/local)\033[0m"
read prefixDir

# 安装目录默认值
if [[ -z $prefixDir ]]
then
    prefixDir=$prefixDirDefault
fi

echo -e "\033[33m安装目录：${prefixDir}\033[0m"

# 检查安装目录下是否已经存在该程序
if [[  -d "${prefixDir}/${apacheInstallName}" ]]
then
    echo -e "\033[31mDo you want to re install Apache? [Y/n]: \033[0m"
    while read  apache_isCover
    do
        if [[ -z $apache_isCover ]] || [[ -n $(echo $apache_isCover|egrep -i "^(yes|y)$") ]]
        then
            # 覆盖，重新安装apache
            installApache
            break
        elif [[ -z $(echo $apache_isCovet|egrep -i "^(no|n)$") ]]
        then
            # 不覆盖安装apache
            break
        fi
    done

else
    # 安装apache
    installApache
fi


