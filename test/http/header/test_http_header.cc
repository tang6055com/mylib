//  Copyright (c) 2015-2016 The kid Authors. All rights reserved.
//   Created on: 2016.12.23 Author: kerry

#include "gtest/gtest.h"
#include "logic/logic_comm.h"
#include "basic/basictypes.h"
#include "log/mig_log.h"
#include "logic/base_values.h"
#include "basic/radom_in.h"
#include "http/http_header.h"
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
    LOG_MSG2("request_header is empty %d", request_header.IsEmpty());
    request_header.SetHeader("Accept-Encoding","gzip, deflate, sdch, br");
    request_header.SetHeader("Accept-Language","zh-CN,zh;q=0.8,en;q=0.6");
    request_header.SetHeader("User-Agent","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36");
    std::string t = request_header.ToString();
    LOG_MSG2("%s",t.c_str());
    LOG_MSG2("request_header is empty %d", request_header.IsEmpty());
    LOG_MSG2("request_header has User-Agent %d", request_header.HasHeader("User-Agent"));
    LOG_MSG2("request_header has Mod %d", request_header.HasHeader("Mod"));
    std::string user_agent;
    std::string encoding;
    bool r = request_header.GetHeader("User-Agent", &user_agent);
    if(r)
        LOG_MSG2("%s",user_agent.c_str());

    request_header.RemoveHeader("User-Agent");


    t = request_header.ToString();
    LOG_MSG2("======>%s",t.c_str());
    
    request_header.AddHeaderFromString("Connection:keep-alive\r\nHost:xueqiu.com\r\nReferer:https://xueqiu.com/");
    
    t = request_header.ToString();
    LOG_MSG2("======>%s",t.c_str());
    


    base_http::HttpRequestHeader  t_request_header;
    //t_request_header.SetHeader("X-Requested-With","XMLHttpRequest");
    //t_request_header.SetHeader("User-Agent","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36");

    //t = t_request_header.ToString();
   // LOG_MSG2("======>%s",t.c_str());
    
    t_request_header.CopyFrom(request_header);
    t = request_header.ToString();
    LOG_MSG2("======>%s",t.c_str());
    /*r = request_header.GetHeader("User-Agent", &user_agent);
    if (!r)
        LOG_MSG("no have User-Agent");
    else
        LOG_MSG("have user_agent");*/
    //return 0;	
}
