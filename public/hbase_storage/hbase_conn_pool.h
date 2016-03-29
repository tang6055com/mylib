/*=============================================================================
#    Copyright (c) 2015
#    ShanghaiKunyan.  All rights reserved
#
#    Filename     : /home/tianyiheng_test/HbaseLib/include/hbase_conn_pool.h
#    Author       : tianyiheng
#    Email        : tianyiheng@kunyan-inc.com
#    Date         : 2016-03-08 13:46
#    Description  : 
=============================================================================*/

#ifndef __HBASE_CONN_POOL_H__
#define __HBASE_CONN_POOL_H__

#include <stdio.h>                     
#include <unistd.h>                    
#include <sys/time.h>                  
#include <poll.h>                      
#include <pthread.h>                   
                                       
#include <queue>                       
#include <iostream>                    
#include <memory>                      
                                       
#include <boost/lexical_cast.hpp>      
#include <protocol/TBinaryProtocol.h>  
#include <transport/TSocket.h>         
#include <transport/TTransportUtils.h> 
                                       
#include "Hbase.h"

using namespace apache::thrift;                       
using namespace apache::thrift::protocol;             
using namespace apache::thrift::transport;            
                                                      
using namespace apache::hadoop::hbase::thrift;        
using namespace std;                                  
                                                      
                                                      
typedef std::map<std::string, std::string> RowDataMap;
#define MIN_HBASE_POOL_SIZE     2



namespace storage {

// DbHbaseImpl
class DbHbaseImpl{
  public:
    DbHbaseImpl();
    ~DbHbaseImpl();

    bool Init(std::string host, int port);
    void Close();

  protected:
    boost::shared_ptr<TTransport> socket_ptr_;    
    boost::shared_ptr<TTransport> transport_ptr_; 
    boost::shared_ptr<TProtocol> protocol_ptr_; 
    boost::shared_ptr<HbaseClient> client_ptr_;

  public:                                                                               
    void GetRowData(std::string &table_name, std::string &row_key, RowDataMap & data_map);
    void GetColumnData(std::string &table_name, std::string &row_key,                     
        std::string &column_name, std::string &column_data);                             

};


// DbHbaseConnPool is a singleton
class DbHbaseConnPool{
  protected:
    DbHbaseConnPool();
    ~DbHbaseConnPool();
    void ReleaseConnect();
  public:
    static DbHbaseConnPool* GetInstance();
    static void ReleaseInstance();
    static void InitPool(std::string host, int port, int num = MIN_HBASE_POOL_SIZE);
  public:
    void Init(std::string host, int port, int num = MIN_HBASE_POOL_SIZE);
    DbHbaseImpl* PopConn();
    void PushConn(DbHbaseImpl *conn);

  private:
    std::queue<DbHbaseImpl*> db_hbase_connect_queue_;
    std::string host_;
    int port_;        
    
  protected:                                
  // mutex lock                           
    pthread_mutex_t hbase_mutext_;

  // static member
  static pthread_mutex_t s_hbase_pool_mutext_;
  static DbHbaseConnPool* s_hbase_conn_pool_ptr_;
};

} // namespace storage end

#endif
