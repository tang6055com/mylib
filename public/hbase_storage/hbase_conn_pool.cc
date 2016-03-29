/*=============================================================================
#    Copyright (c) 2015
#    ShanghaiKunyan.  All rights reserved
#
#    Filename     : /home/tianyiheng_test/HbaseLib/include/hbase_conn_pool.cc
#    Author       : Tianyiheng
#    Email        : tianyiheng@kunyan-inc.com
#    Date         : 2016-03-08 14:01
#    Description  : 
=============================================================================*/

#include "hbase_conn_pool.h"

namespace storage {

DbHbaseImpl::DbHbaseImpl(){
  
}

DbHbaseImpl::~DbHbaseImpl(){

}

bool DbHbaseImpl::Init(std::string host, int port){
  try{
    socket_ptr_.reset(new TSocket(host.c_str(), port));
    transport_ptr_.reset(new TBufferedTransport(socket_ptr_));
    protocol_ptr_.reset(new TBinaryProtocol(transport_ptr_));
    client_ptr_.reset(new HbaseClient(protocol_ptr_));
    transport_ptr_->open();
  }catch(const TException &tx){
      return false;
  } 
  return true;
}

void DbHbaseImpl::GetRowData(std::string &table_name, std::string &row_key, RowDataMap & data_map){
  std::vector<TRowResult> vec_result;                                                    
  std::map<Text, Text>  map_attr;                                                        
  client_ptr_->getRow(vec_result, table_name, row_key, map_attr);                        
  for (size_t i = 0; i < vec_result.size(); ++i){                                        
    for(std::map<std::string, TCell>::const_iterator it = vec_result[i].columns.begin(); 
            it != vec_result[i].columns.end(); ++it){                                          
        data_map.insert(make_pair(it->first, it->second.value));                         
    }                                                                                  
  }
}

void DbHbaseImpl::GetColumnData(std::string &table_name, std::string & row_key,
        std::string &column_name, std::string &column_data){
    std::vector<TRowResult> vec_result;                                                    
    std::map<Text, Text>  map_attr;                                                        
    std::vector<Text> vec_columns;                                                         
    vec_columns.push_back(column_name);                                                    
    client_ptr_->getRowWithColumns(vec_result, table_name, row_key, vec_columns, map_attr);
    if (vec_result.size() > 0){                                                            
      for(std::map<std::string, TCell>::const_iterator it = vec_result[0].columns.begin(); 
              it != vec_result[0].columns.end(); ++it){                                          
        column_data = it->second.value;                                                  
        break;                                                                           
      }                                                                                  
    }
}

void DbHbaseImpl::Close(){
  transport_ptr_->close();
}

// DbHbaseConn pool

DbHbaseConnPool* DbHbaseConnPool::s_hbase_conn_pool_ptr_ = NULL;
pthread_mutex_t DbHbaseConnPool::s_hbase_pool_mutext_;

DbHbaseConnPool::DbHbaseConnPool(){
  
}

DbHbaseConnPool::~DbHbaseConnPool(){
 ReleaseConnect(); 
}

void DbHbaseConnPool::ReleaseConnect(){
  while(db_hbase_connect_queue_.size() > 0){
    DbHbaseImpl* hbase_impl = db_hbase_connect_queue_.front();
    if (NULL != hbase_impl){
      hbase_impl->Close();
      delete hbase_impl;
    }
    db_hbase_connect_queue_.pop();
  }
}

void DbHbaseConnPool::Init(std::string host, int port, int num){
  host_ = host;                               
  port_ = port;
  if (num <= 0){
    num = MIN_HBASE_POOL_SIZE;
  } 
  // init ..                                    
  pthread_mutex_init(&hbase_mutext_, NULL);
  for(int i = 0; i < num; ++i){
    pthread_mutex_lock(&hbase_mutext_);
    DbHbaseImpl *hbase_ptr = new DbHbaseImpl;           
    if (NULL != hbase_ptr){
      hbase_ptr->Init(host_, port_);        
      db_hbase_connect_queue_.push(hbase_ptr);
      hbase_ptr = NULL;
    }
    pthread_mutex_unlock(&hbase_mutext_);     
  } 
}

DbHbaseImpl* DbHbaseConnPool::PopConn(){
  DbHbaseImpl* ret = NULL;                       
  pthread_mutex_lock(&hbase_mutext_);      
  if (0 < db_hbase_connect_queue_.size()){ 
    ret = db_hbase_connect_queue_.front(); 
    db_hbase_connect_queue_.pop();         
  }else{                                     
    ret = new DbHbaseImpl;
    ret->Init(host_, port_);
  }                                          
  pthread_mutex_unlock(&hbase_mutext_);
  return ret;                                
}

void  DbHbaseConnPool::PushConn(DbHbaseImpl *conn){
  if(NULL != conn){
    pthread_mutex_lock(&hbase_mutext_);     
    db_hbase_connect_queue_.push(conn);
    pthread_mutex_unlock(&hbase_mutext_);
  }
}

// static method

void DbHbaseConnPool::InitPool(std::string host, int port, int num){
  pthread_mutex_init(&s_hbase_pool_mutext_, NULL);

  DbHbaseConnPool *pool_ptr = DbHbaseConnPool::GetInstance();
  if (NULL != pool_ptr){
    pool_ptr->Init(host, port, num);   
  }
}
  
DbHbaseConnPool* DbHbaseConnPool::GetInstance(){
  if(NULL == s_hbase_conn_pool_ptr_){
    pthread_mutex_lock(&s_hbase_pool_mutext_);
    if (NULL == s_hbase_conn_pool_ptr_){
      s_hbase_conn_pool_ptr_ = new DbHbaseConnPool();
    }
    pthread_mutex_unlock(&s_hbase_pool_mutext_);
  }
  return s_hbase_conn_pool_ptr_;
}

void DbHbaseConnPool::ReleaseInstance(){
    if (NULL != s_hbase_conn_pool_ptr_){
      pthread_mutex_lock(&s_hbase_pool_mutext_);
      if (NULL != s_hbase_conn_pool_ptr_){
        delete s_hbase_conn_pool_ptr_;
        s_hbase_conn_pool_ptr_ = NULL;
      }
      pthread_mutex_unlock(&s_hbase_pool_mutext_);   
    }
}

} // namespace storage end
