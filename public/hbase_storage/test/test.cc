/*=============================================================================
#    Copyright (c) 2015
#    ShanghaiKunyan.  All rights reserved
#
#    Filename     : /home/tianyiheng_test/HbaseLib/hbase_storage/test/test.cc
#    Author       : Tianyiheng
#    Email        : tianyiheng@kunyan-inc.com
#    Date         : 2016-03-08 16:16
#    Description  : 
=============================================================================*/

#include "../hbase_conn_pool.h"
#include "../hbase_accessor.h"
#include <iostream>
using namespace std;


int main(int argc, char* argv[]){
  
  cout<<"hello c++ hbase test"<<endl;

  storage::DbHbaseConnPool::InitPool("222.73.34.92", 9090, 2);
  storage::HbaseAccessor db_hbase;
  
  std::string news_url = "http://stock.sohu.com/20160307/n439639145.shtml"; 
  if (argc > 1){
    news_url = argv[1];
  }
  std::string column_data;
  db_hbase.GetColumnData("wk_detail", news_url, "basic:content", column_data);
  if (column_data.length()>0){
    cout<<"News content:"<<column_data<<endl; 
  }
  else{
    cout<<"No date recved"<<endl;
  }

  storage::DbHbaseConnPool::ReleaseInstance();
  cout<<"finished test"<<endl;
  return 0;
}

