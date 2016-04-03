/*=============================================================================
#    Copyright (c) 2015
#    ShanghaiKunyan.  All rights reserved
#
#    Filename     : /home/tianyiheng_test/HbaseLib/hbase_storage/readme.txt
#    Author       : Tianyiheng
#    Email        : tianyiheng@kunyan-inc.com
#    Date         : 2016-03-09 09:39
#    Description  : 
=============================================================================*/


依赖的环境配置,此静态库编译时环境配置如下:

1.libevent-2.0.21-stable
2.thrift-0.9.3, 安装目录为/usr/local/thrift
3.boost_1_57_0, 安装目录为/usr/local/boost
4.hbase-0.94.27，这个在客户机不用安装，主要是初次使用时提取里面的thrift脚本文件

如果配置有变，相应的makefile也需要改变一下

