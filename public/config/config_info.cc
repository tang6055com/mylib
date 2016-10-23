/*
 * config_info.cc
 *
 *  Created on: 2016年10月22日
 *      Author: kerry
 */

#include "config_info.h"

namespace base {

ConnAddr::ConnAddr() {

  data_ = new Data();
}

ConnAddr::ConnAddr(const int32 id, const std::string& host, const int port,
                   const std::string& usr, const std::string& pwd,
                   const std::string& source, const std::string& desc,
                   const std::string& additional) {

  data_ = new Data(id, host, port, usr, pwd, source, desc, additional);
}

ConnAddr& ConnAddr::operator=(const ConnAddr& ca) {
  if (ca.data_ != NULL) {
    ca.data_->AddRef();
  }
  if (data_ != NULL) {
    data_->Release();
  }

  data_ = ca.data_;
  return *this;
}

ConnAddr::ConnAddr(const ConnAddr& ca)
    : data_(ca.data_) {
  if (data_ != NULL) {
    data_->AddRef();
  }
}

}

