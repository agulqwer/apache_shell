#!/bin/bash

# 安装依赖
deps=("gcc" "gcc-c++"  "make" "wget")
for i in ${deps[@]}
do
    if [[ -z $(rpm -qa| grep $i) ]] || [[ -z $(command -v $i) ]] 
    then
        yum install -y $i
    fi
done

# 安装依赖库
# 定义依赖数组
declare -A depsName
declare -A depsFunc

depsName["apr"]=$aprInstallName
depsName["apr_util"]=$aprUtilInstallName
depsName["pcre"]=$pcreInstallName

depsFunc["apr"]="installApr"
depsFunc["apr_util"]="installAprUtil"
depsFunc["pcre"]="installPcre"

for key in ${!depsName[*]}
do
    # 检查安装目录下是否已经存在该程序
    if [[  -d "${prefixDir}/${depsName[$key]}" ]]
    then
        echo -e "\033[31mDo you want to re install ${key}? [Y/n]:\033[0m"
        while read  isCover
        do
            if [[ -z $isCover ]] || [[ -n $(echo $sCover|egrep -i "^(yes|y)$") ]]
            then
                # 覆盖，重新安装apr
                ${depsFunc[$key]}
                break
            elif [[ -z $(echo $isCover|egrep -i "^(no|n)$") ]]
            then
                # 不覆盖安装apr
                break
            fi
        done

    else
        # 安装apr
        ${depsFunc[$key]}
    fi
done

