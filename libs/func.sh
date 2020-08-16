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

        # 程序名
        getCodePkgName=$5
        # 查询可安装包
        getCodes=($(find $getCodeDir -regex $getCodeRegex))

        # 判断本地是否存在安装包
        if [[ -z $getCodes ]]
        then
            # 下载线上版本
            wget -P $getCodeDown $getCodeUrl
            getCodeTmp=${getCodeUrl##*/}
            getCodeReturn=$(find $getCodeDir -name $getCodeTmp)
        else
            if [[ ${#getCodes[@]} -eq 1 ]]
            then
                # 本地只有一个源码包
                getCodeReturn=${getCodes[0]}
            else
                echo -e "\033[33mYou have ${#getCodes[@]} ${getCodePkgName} package for select\033[0m"
                local count=1
                local readData=""
                local index=0
                for ((i=0;i<${#getCodes[@]};i++))
                do
                    ((index+=1))
                    echo "${index}: ${getCodes[i]}"
                    if [[ $i -eq 0 ]]
                    then
                        count="${index}"
                    else
                        count="${count},${index}"
                    fi
                done
                while read -p "Enter your choice (${count}):" readData
                do
                    if [[ $readData -gt 0 ]] && [[ $readData -le ${#getCodes[@]} ]]
                    then
                        let readData=$readData-1
                        getCodeReturn=${getCodes[$readData]}
                        break
                    elif [[ -z $readData ]]
                    then
                        getCodeReturn=${getCodes[0]}
                        break
                    fi
                done

            fi
       fi

       if [[ -z $getCodeReturn ]]
       then
            echo -e "\033[31mNot Found ${getCodePkgName}\033[0m"
            exit 1
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


# 安装apache函数

function installApache(){
    
    # 删除解压目录下的文件
    if [[ -d "${baseDir}/tar" ]]
    then
        rm $baseDir"/tar/*" -rf
    else
        mkdir "$baseDir/tar"
    fi

    # 删日志目录下的日志文件
    rm "${baseDir}/logs/*" -rf


    # 获取httpd源码包路径并解压
    getCode $baseDir $baseDir"/source/apache" $httpdDownUrl ".*httpd.*.tar[.gz]*" "Apache"
    httpdPkg=$getCodeReturn
    echo -e "\033[33mYou have selected ${httpdPkg}\033[0m"

    # 检查依赖
    source "${baseDir}/libs/deps.sh" 

    configure $httpdPkg $baseDir"/tar" ".*/tar/httpd[^/]*" "--prefix=${prefixDir}/${apacheInstallName} --with-apr=${prefixDir}/apr --with-apr-util=${prefixDir}/apr-util --with-pcre=${prefixDir}/pcre"

    # 配置环境变量
    if [[ ! $(grep "PATH=\$PATH:${prefixDir}/${apacheInstallName}/bin" /etc/profile) ]]
    then
        echo "PATH=\$PATH:${prefixDir}/${apacheInstallName}/bin" >> /etc/profile
        echo "export PATH"
    fi

    source /etc/profile

    # 将apache注册到linux服务中
    \cp -rf  "${prefixDir}/${apacheInstallName}/bin/apachectl" /etc/rc.d/init.d/httpd

    # 判断linux 版本
    if [[ $(cat /etc/redhat-release|sed -r 's/.* ([0-9]?)\..*/\1/') -eq 6 ]]
    then
        # centos 6版本
        service httpd start
    else
        # 添加systemctl服务管理
        \cp -rf "${baseDir}/libs/apache/httpd.service" /etc/systemd/system/httpd.service
        # 重载systemctl
        systemctl daemon-reload
        systemctl stop httpd
        # 开启服务
        systemctl start httpd
    fi
}


# 安装apr函数
function installApr(){
    # 获取源码包路径
    getCode $baseDir "${baseDir}/source/deps/apr/" $aprDownUrl ".*apr[0-9\.-]+.tar[.gz]*" "Apr"
    aprPkg=$getCodeReturn
    # 编译安装
    configure $aprPkg "${baseDir}/tar" ".*/tar/apr[0-9\.-]+" "--prefix=${prefixDir}/${aprInstallName}"
}

# 安装apr-util函数
function installAprUtil(){
    # 获取源码路径
    getCode $baseDir "${baseDir}/source/deps/apr" $aprUtilDownUrl ".*apr.*util[0-9\.-]+.tar[.gz]*" "Apr-util"
    aprUtilPkg=$getCodeReturn 
    # 编译安装
    configure $aprUtilPkg "$baseDir/tar" ".*/tar/apr.*util[0-9\.-]+" "--prefix=${prefixDir}/${aprUtilInstallName} --with-apr=${prefixDir}/${aprInstallName}/bin/apr-1-config"
}

# 安装pcre函数
function installPcre(){
    # 获取源码路径
    getCode $baseDir "$baseDir/source/deps/pcre" $pcreDownUrl ".*pcre[0-9\.-]+.tar[.gz]*" "Pcre"
    pcrePkg=$getCodeReturn 
    # 编译安装
    configure $pcrePkg "$baseDir/tar" ".*/tar/pcre[0-9\.-]+" "--prefix=${prefixDir}/${pcreInstallName} --with-apr=${prefixDir}/${aprInstallName}/bin/apr-1-config" 
}
