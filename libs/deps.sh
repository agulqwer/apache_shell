#!/bin/bash

baseDir=$1
prefixDir=$2
# 安装依赖
deps=("gcc" "make" "wget")
for i in ${deps[@]}
do
    if [[ -z $(rpm -qa| grep $i) ]] || [[ -z $(command -v $i) ]] 
    then
        yum install -y $i
    fi
done

. libs/func.sh
# 安装apr
# 线上源码路径
aprDownUrl="http://archive.apache.org/dist/apr/apr-1.5.2.tar.gz"
aprPkg=$(getCode $baseDir "${baseDir}/source" $aprDownUrl ".*apr[0-9\.-]+.tar[.gz]*")

# 编译安装
configure $aprPkg "${baseDir}/tar" ".*/tar/apr[0-9\.-]+" "--prefix=${prefixDir}/apr"

# 安装apr-util
aprUtilDownUrl="http://archive.apache.org/dist/apr/apr-util-1.3.12.tar.gz"
aprUtilPkg=$(getCode $baseDir "${baseDir}/source" $aprUtilDownUrl ".*apr.*util[0-9\.-]+.tar[.gz]*")

# 编译安装
configure $aprUtilPkg "$baseDir/tar" ".*/tar/apr.*util[0-9\.-]+" "--prefix=${prefixDir}/apr-util --with-apr=${prefixDir}/apr/bin/apr-1-config"

# 安装pcre库
pcreDownUrl="http://jaist.dl.sourceforge.net/project/pcre/pcre/8.35/pcre-8.35.tar.gz"
pcrePkg=$(getCode $baseDir "$baseDir/source" $pcreDownUrl ".*pcre[0-9\.-]+.tar[.gz]*")

# 编译安装
configure $pcrePkg "$baseDir/tar" ".*/tar/pcre[0-9\.-]+" "--prefix=${prefixDir}/pcre --with-apr=${prefixDir}/apr/bin/apr-1-config"

