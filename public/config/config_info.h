//  Copyright (c) 2015-2015 The Mylib Authors. All rights reserved.
//  Created on: 2016年10月22日 Author: kerry

#ifndef MYLIB_PUBLIC_CONFIG_CONFIG_INFO_H__
#define MYLIB_PUBLIC_CONFIG_CONFIG_INFO_H__

#include <string>
#include "basic/basictypes.h"

namespace base {

class ConnAddr {
 public:
  explicit ConnAddr();
  explicit ConnAddr(const int32 id, const std::string& host, const int port,
                    const std::string& usr = "", const std::string& pwd = "",
                    const std::string& source = "", const std::string& desc = "",
                    const std::string& additional = "");

  ConnAddr(const ConnAddr& ca);
  ConnAddr& operator = (const ConnAddr& ca);

  ~ConnAddr() {
    if (data_ != NULL) {
      data_->Release();
    }
  }


  const int32 id() const {return data_->id_;}
  const int port() const {return data_->port_;}
  const std::string& host() const {return data_->host_;}
  const std::string& usr() {return data_->usr_;}
  const std::string& pwd() {return data_->pwd_;}
  const std::string& source() {return data_->source_;}
  const std::string& desc() {return data_->desc_;}
  const std::string& additional() {return data_->additional_;}

private:
  class Data {
  public:
    Data():refcount_(1),port_(0),id_(-1) {}
    Data(const int32 id,
         const std::string& host,
         const int port,
         const std::string& usr,
         const std::string& pwd,
         const std::string& source,
         const std::string& desc,
         const std::string& additional)
    :id_(id)
    ,host_(host)
    ,port_(port)
    ,usr_(usr)
    ,pwd_(pwd)
    ,source_(source)
    ,desc_(desc)
    ,refcount_(1) {}
    void AddRef() {refcount_++;}
    void Release() {if(!--refcount_) delete this;}
    const int32 id_;
    const int port_;
    const std::string host_;
    const std::string usr_;
    const std::string pwd_;
    const std::string source_;
    const std::string desc_;
    const std::string additional_;
  private:
    int refcount_;
  };

  Data* data_;
};

}


#endif /* MYLIB_PUBLIC_CONFIG_CONFIG_XML_H__ */
