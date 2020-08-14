#/bin/bash

# 变量
baseDir=$(pwd)
httpdDownUrl="https://mirrors.bfsu.edu.cn/httpd//httpd/httpd-2.4.46.tar.gz"

# 删除解压目录下的文件
rm $baseDir"/tar/*" -rf

# 删日志目录下的日志文件
rm "${baseDir}/logs/*" -rf
# 输入安装目录
echo "-----------------------"
echo "-----------------------"
echo "输入安装目录"
read prefixDir

# 检查依赖
./libs/deps.sh $baseDir $prefixDir

# 获取httpd源码包路径
. libs/func.sh
httpdPkg=$(getCode $baseDir $baseDir"/source" $httpdDownUrl ".*httpd.*.tar[.gz]*") 

configure $httpdPkg $baseDir"/tar" ".*/tar/httpd[^/]*" "--prefix=${prefixDir}/apache --with-apr=${prefixDir}/apr --with-apr-util=${prefixDir}/apr-util --with-pcre=${prefixDir}/pcre"

# 配置环境变量
if [[ ! $(grep "PATH=/$PATH:${prefixDir}/apache/bin" /etc/profile) ]]
then
    echo "PATH=\$PATH:${prefixDir}/apache/bin" >> /etc/profile
    echo "export PATH"
fi

source /etc/profile

# 将apache注册到linux服务中
\cp -rf  "${prefixDir}/apache/bin/apachectl" /etc/rc.d/init.d/httpd

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
