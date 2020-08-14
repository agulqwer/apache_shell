#!/bin/bash

# 获取源码包
    function getCode(){
        # 本地查找目录
        getCodeDir=$1
        # 线上文件下载目录
        getCodeDown=$2
        # 获取线上文件路径
        getCodeUrl=$3
        # 匹配文件正则表达式
        getCodeRegex=$4

        # 查询可安装包
        getCodes=($(find $getCodeDir -regex $getCodeRegex))

        # 判断本地是否存在安装包
        if [[ -z $getCodes ]]
        then
            # 下载线上版本
            wget -P $getCodeDown $getCodeUrl
            getCodeTmp=${getCodeUrl##*/}
            echo $(find $getCodeDir -name $getCodeTmp)
        else
            if [[ ${#getCodes[@]} -eq 1 ]]
            then
                # 本地只有一个源码包
                echo ${getCodes[0]}
            else
                echo "选择httpd版本"
                select name in ${getCodes[@]}
                do
                    echo $name
                    break
                done
            fi
        fi
    }


# 解压、编译安装
function configure(){
    # 解压包
    cfg_pkg=$1

    # 解压目录
    cfg_pressDir=$2

    # 查找解压目录正则表达式
    cfg_findRegex=$3

    # configure配置参数
    cfg_args=$4

    # 获取安装软件名
    pkgName=$(echo $4|awk -F ' {1,}' '{print $1}')
    pkgName=${pkgName##*/}

    # 获取根目录
    baseDir=${2%tar*}

    # 解压源码包
    if [[ ${cfg_pkg##*.} = "gz" ]]
    then
        tar -zxvf $cfg_pkg -C $cfg_pressDir
    elif [[ ${cfg_pkg##*.} = "tar" ]]
    then
        tar -xvf $cfg_pkg -C $cfg_pressDir
    fi

    # 进入解压目录
    cfg_tarDir=$(find $cfg_pressDir -regex $cfg_findRegex)
    cd $cfg_tarDir

    # 软件的配置与检查
    ./configure $cfg_args

    #编译
    make 1> "${baseDir}/logs/${pkgName}_install.log"
    make install 1> "${baseDir}/logs/${pkgName}_install.log"
}
