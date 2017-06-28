//  Copyright (c) 2015-2016 The kid Authors. All rights reserved.
//   Created on: 2016.12.23 Author: kerry

#include "gtest/gtest.h"
#include "logic/logic_comm.h"
#include "basic/basictypes.h"
#include "log/mig_log.h"
#include "logic/base_values.h"
#include "basic/radom_in.h"
#include "http/http_header.h"
#include "http/http_api.h"
#include <string>

class QueueKafkaTest: public testing::Test {
};

#include <ctype.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <syslog.h>
#include <sys/time.h>
#include <errno.h>
#include "rdkafka.h"



TEST(HttpHeaderTest, Basic){
    LOG_MSG("============>");
    base_http::HttpRequestHeader  request_header;
    request_header.SetHeader("Authorization","APPCODE e361298186714a6faea52316ff1d5c32");
    std::string strResult;
    std::string strUrl = "http://idcardreturnphoto.haoservice.com/idcard/VerifyIdcardReturnPhoto";
    std::string idcard;
    std::string name;
    base_logic::DictionaryValue dic;
    dic.SetString(L"cardNo", idcard);
    dic.SetString(L"realName", name);
    base_http::HttpAPI::RequestGetMethod(strUrl, &dic, & request_header, strResult, 1);

    
    //return 0;	
    LOG_DEBUG2("strResult [%s]___________________________________________________", strResult.c_str());
}
