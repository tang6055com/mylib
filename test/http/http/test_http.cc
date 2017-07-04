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
    //request_header.SetHeader("Authorization","APPCODE e361298186714a6faea52316ff1d5c32");
    //request_header.SetHeader("User-Agent","Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36");
    //request_header.SetHeader("Cookie","webp=1; s=7h123d58x9; bid=ac54c07d551db7685df4141da06bac1e_izt9cthe; device_id=dd9b2af7ecd94fad858478a06ce655ec; __utma=1.1688381833.1492787403.1498202471.1498699530.13; __utmz=1.1498202471.12.2.utmcsr=baidu|utmccn=(organic)|utmcmd=organic|utmctr=%E7%88%B1%E5%BA%B7%E5%9B%BD%E5%AE%BE%20%E8%82%A1%E7%A5%A8; aliyungf_tc=AQAAAKyF4QOTRgsAQ3DNc1XBDsUjOTvv; xq_a_token=0a52c567442f1fdd8b09c27e0abb26438e274a7e; xq_a_token.sig=dR_XY4cJjuYM6ujKxH735NKcOpw; xq_r_token=43c6fed2d6b5cc8bc38cc9694c6c1cf121d38471; xq_r_token.sig=8d4jOYdZXEWqSBXOB9N5KuMMZq8; u=721498734029290; Hm_lvt_1db88642e346389874251b5a1eded6e3=1498351396,1498629138,1498698102,1498734030; Hm_lpvt_1db88642e346389874251b5a1eded6e3=1498734173");
    std::string strResult;
    //std::string strUrl = "http://idcardreturnphoto.haoservice.com/idcard/VerifyIdcardReturnPhoto";
    std::string strUrl = "https://xueqiu.com";
    std::string idcard;
    std::string name;
    base_logic::DictionaryValue dic;
    dic.SetString(L"pageNo","5");
    dic.SetString(L"uid", "1004906134");
    //dic.SetString(L"cardNo", idcard);
    //dic.SetString(L"realName", name);
    base_http::HttpAPI::RequestGetMethod(strUrl, &dic, & request_header, strResult, 1);

    
    //return 0;	
    LOG_DEBUG2("strResult [%s]___________________________________________________", strResult.c_str());
}
