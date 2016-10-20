/*=============================================================================
#    Copyright (c) 2015
#    ShanghaiKunyan.  All rights reserved
#
#    Filename     : /home/tianyiheng_test/HbaseLib/hbase_storage/hbase_accessor.h
#    Author       : tianyiheng
#    Email        : tianyiheng@kunyan-inc.com
#    Date         : 2016-03-08 18:56
#    Description  : 
=============================================================================*/

#ifndef __HBASE_ACCESSOR_H__
#define __HBASE_ACCESSOR_H__

#include "./hbase_conn_pool.h"

namespace storage{

class HbaseAccessor{
  public:
    HbaseAccessor();
    ~HbaseAccessor();

    void GetRowData(std::string table_name, std::string row_key, RowDataMap & data_map);
    void GetColumnData(std::string table_name, std::string row_key,                     
            std::string column_name, std::string &column_data);

  private:
    DbHbaseImpl *hbase_impl_ptr_;
};


} //namespace storage end


#endif

