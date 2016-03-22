/*=============================================================================
#    Copyright (c) 2015
#    ShanghaiKunyan.  All rights reserved
#
#    Filename     : /home/tianyiheng_test/HbaseLib/hbase_storage/hbase_accessor.cc
#    Author       : Tianyiheng
#    Email        : tianyiheng@kunyan-inc.com
#    Date         : 2016-03-08 18:58
#    Description  : 
=============================================================================*/
#include "hbase_accessor.h"
namespace storage{

HbaseAccessor::HbaseAccessor():
  hbase_impl_ptr_(NULL){
  hbase_impl_ptr_ = DbHbaseConnPool::GetInstance()->PopConn();
}


HbaseAccessor::~HbaseAccessor(){
  if (NULL != hbase_impl_ptr_){
    DbHbaseConnPool::GetInstance()->PushConn(hbase_impl_ptr_);
  }
}

void HbaseAccessor::GetRowData(std::string table_name, 
     std::string row_key, RowDataMap & data_map){
  if (NULL != hbase_impl_ptr_){
    hbase_impl_ptr_->GetRowData(table_name, row_key, data_map); 
  }
}

void HbaseAccessor::GetColumnData(std::string table_name, std::string row_key,                     
        std::string column_name, std::string &column_data){
  if(NULL != hbase_impl_ptr_){
    hbase_impl_ptr_->GetColumnData(table_name, row_key, column_name, column_data); 
  }
}                             


} // namespace storage end

