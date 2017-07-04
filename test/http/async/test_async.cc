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
#include "curl/curl.h"
#include <string>
#include <list>
#include <vector>
class AsyncTest: public testing::Test {
};

#include <ctype.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <syslog.h>
#include <sys/time.h>
#include <errno.h>

#include <event2/event.h>
#include <event2/event_struct.h>
#include <event2/util.h>



struct CurlContent{
	std::map<std::string,std::list<std::string> >*   headers_;
	std::vector<char>                   *content_;
	int                                 code_;
	int                                 subversion_;
	uint32                              max_num_;
};


static size_t ContentFunction(void *ptr, size_t size, size_t nmemb,
							  void *content){

    CurlContent* curl_content = (CurlContent*)content;
    
    if(curl_content->content_->size()<curl_content->max_num_){
        curl_content->content_->insert(curl_content->content_->end(),
             (char*)ptr,(char*)ptr+std::min(size*nmemb,
             curl_content->max_num_ - curl_content->content_->size()));	
    }
    return size*nmemb;
}


TEST(AsyncTest, Basic){
    base_http::HttpRequestHeader  request_header;
    //request_header.SetHeader("Authorization","APPCODE e361298186714a6faea52316ff1d5c32");
    std::string strResult;
    std::string strUrl = "https://xueqiu.com";
    std::string idcard;
    std::string name;
    std::vector<char> content;
    std::map<std::string,std::list<std::string> >  header;
    
    //base_logic::DictionaryValue dic;
    //dic.SetString(L"cardNo", idcard);
    //dic.SetString(L"realName", name);
    char curl_error[CURL_ERROR_SIZE];
    CurlContent curl_content;
    CURL* curl = curl_easy_init();
    CURLM *multi_handle = curl_multi_init();
    curl_easy_setopt(curl, CURLOPT_URL, strUrl.c_str());
    curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, curl_error);
    curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1);
    curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
    curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION,ContentFunction);
    curl_easy_setopt(curl,CURLOPT_WRITEDATA,&curl_content);
    
    curl_content.code_ = 0;
    curl_content.content_ = &content;
    curl_content.headers_ =  &header;
    curl_content.subversion_ = 0;
    curl_content.max_num_ = 1024*1024;
/*
    curl_easy_perform(curl);

    curl_easy_cleanup(curl);
    std::string t;
    for(std::vector<char>::iterator itr = content.begin();
        itr!=content.end();++itr){
            t.append(1,(*itr));
    }

    printf("%s", t.c_str());*/
    curl_multi_add_handle(multi_handle, curl);

    int running_handle_count;
    


  /*  fd_set  fd_read;
    fd_set  fd_write;
    fd_set  fd_except;
    
    
    FD_ZERO(&fd_read);
    FD_ZERO(&fd_write);
    FD_ZERO(&fd_except);

    int max_fd = -1;

    curl_multi_fdset(multi_handle, &fd_read, &fd_write, &fd_except, &max_fd);
    
*/
    while(CURLM_CALL_MULTI_PERFORM == curl_multi_perform(multi_handle, &running_handle_count)) {
        printf("running_handle_count:%d",running_handle_count);
    }

    while(running_handle_count) {
        int max_fd;
        timeval tv;
        tv.tv_sec = 1;
        tv.tv_usec = 0;
        fd_set fd_read;
        fd_set fd_write;
        fd_set fd_except;

        FD_ZERO(&fd_read);
        FD_ZERO(&fd_write);
        FD_ZERO(&fd_except);

        curl_multi_fdset(multi_handle, &fd_read, &fd_write, &fd_except, &max_fd);
        
        int return_code = select(max_fd + 1, &fd_read, &fd_write, &fd_except, &tv);
        printf("return_code %d  max_fd %d\r\n",return_code,max_fd);
        if (-1 == return_code){
            printf("select error.\r\n");
            break;
        }else{
            while (CURLM_CALL_MULTI_PERFORM == curl_multi_perform(multi_handle, &running_handle_count)){
                printf("running_handle_count.\r\n");
            }
        }
    }

    std::string t; 
    for(std::vector<char>::iterator itr = content.begin();
        itr!=content.end();++itr){
            t.append(1,(*itr));
    }

//    printf("%s", t.c_str());

}
