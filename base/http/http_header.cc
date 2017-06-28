//  Copyright (c) 2012-2017 The MIGLIB Authors. All rights reserved.
//  Created on: 2017年6月18日 Author: kerry

#include "http/http_header.h"
#include "http/http_util.h"
#include "logic/logic_comm.h"
#include "basic/basic_util.h"
#include <string.h>

namespace base_http {

const char HttpRequestHeader::kGetMethod[] = "GET";
const char HttpRequestHeader::kAcceptCharset[] = "Accept-Charset";
const char HttpRequestHeader::kAcceptEncoding[] = "Accept-Encoding";
const char HttpRequestHeader::kAcceptLanguage[] = "Accept-Language";
const char HttpRequestHeader::kCacheControl[] = "Cache-Control";
const char HttpRequestHeader::kConnection[] = "Connection";
const char HttpRequestHeader::kContentLength[] = "Content-Length";
const char HttpRequestHeader::kContentType[] = "Content-Type";
const char HttpRequestHeader::kCookie[] = "Cookie";
const char HttpRequestHeader::kHost[] = "Host";
const char HttpRequestHeader::kIfModifiedSince[] = "If-Modified-Since";
const char HttpRequestHeader::kIfNoneMatch[] = "If-None-Match";
const char HttpRequestHeader::kIfRange[] = "If-Range";
const char HttpRequestHeader::kOrigin[] = "Origin";
const char HttpRequestHeader::kPragma[] = "Pragma";
const char HttpRequestHeader::kProxyConnection[] = "Proxy-Connection";
const char HttpRequestHeader::kRange[] = "Range";
const char HttpRequestHeader::kReferer[] = "Referer";
const char HttpRequestHeader::kUserAgent[] = "User-Agent";

HttpRequestHeader::HttpRequestHeader() {
    headers_ = new base_logic::ListValue;
}


HttpRequestHeader::~HttpRequestHeader() {
    if (headers_) {delete headers_; headers_ = NULL;}
}

base_logic::ListValue::iterator HttpRequestHeader::FindHeader(const std::string& key) {
    for(base_logic::ListValue::iterator it = headers_->begin();
        it != headers_->end(); ++it) {
            HeaderKeyValuePair key_value((base_logic::DictionaryValue*)(*it));
            std::string header_key = key_value.key();
            if (key.length() == header_key.length() &&
                        !strncasecmp(key.c_str(), header_key.c_str(), key.length()))
                return it;
    }

    return headers_->end();
}



base_logic::ListValue::const_iterator HttpRequestHeader::FindHeaderConst(const std::string& key) {
    for(base_logic::ListValue::const_iterator it = headers_->begin();
        it != headers_->end(); ++it) {
            //std::string header_key = (*it)->key();
            HeaderKeyValuePair key_value((base_logic::DictionaryValue*)(*it));
            std::string header_key = key_value.key();
            if (key.length() == header_key.length() &&
                        !strncasecmp(key.c_str(), header_key.c_str(), key.length()))
                return it;
    }

    return headers_->end();
}




bool HttpRequestHeader::GetHeader(const std::string& key, std::string* out)  { 
    base_logic::ListValue::iterator it = FindHeader(key);
    if (it == headers_->end())
        return false;
    HeaderKeyValuePair key_value((base_logic::DictionaryValue*)(*it));
    std::string header_value = key_value.value();
    out->assign(header_value);
    return true;
}

void HttpRequestHeader::Clear() {
    headers_->Clear();
}

void HttpRequestHeader::SetHeader(const std::string& key, const std::string& value) {
    base_logic::ListValue::iterator it = FindHeader(key);
    if (it != headers_->end()){
        HeaderKeyValuePair header((base_logic::DictionaryValue*)(*it));
        RemoveHeader(key);
        header.AddValue(key,value);
        headers_->Append(header.Get());
    }else {
        HeaderKeyValuePair header(key, value);
        headers_->Append(header.Get());

    }
    
    //headers_->Append(header.Get());
}


void HttpRequestHeader::RemoveHeader(const std::string& key) {
    base_logic::ListValue::iterator it = FindHeader(key);
    if (it != headers_->end()){
        base_logic::Value* value = (base_logic::Value*)(*it);
        headers_->Remove((*value));
    }
}

void HttpRequestHeader::AddHeaderFromString(const std::string& header_line) {
    const std::string::size_type key_end_index = header_line.find(":");
    if (key_end_index == std::string::npos){
        LOG_ERROR2("%s is missing colone delimiter.",
                  header_line.c_str());
        return ;
    }

    if (key_end_index == 0) {
        LOG_ERROR2("%s is missing header key",
                  header_line.c_str());
        return ;
    }

    const std::string header_key(header_line.c_str(), key_end_index);

    const std::string::size_type value_index = key_end_index + 1;

    if (value_index < header_line.size()) {
        std::string header_value(header_line.c_str() + value_index,
                                header_line.length() - value_index);

        std::string::const_iterator header_value_begin = 
            header_value.begin();

        std::string::const_iterator header_value_end = 
            header_value.end();

        HttpUtil::TrimLWS(&header_value_begin, &header_value_end);

        if (header_value_begin == header_value_end) {
            SetHeader(header_key,"");
        }else {
            SetHeader(header_key,std::string(&*header_value_begin,header_value_end - header_value_begin));
        }
    }else if (value_index == header_line.size()) {
            SetHeader(header_key,"");
    }
}

void HttpRequestHeader::AddHeadersFromString(const std::string& headers){ 
    std::vector<std::string> header_line_vector;
    const std::string s = "\r\n";
    //base::BasicUtil::StringUtil::SplitStringUsingSubstr(headers, "\r\n", &header_line_vector);
    base::BasicUtil::StringUtil::SplitStringUsingSubstr(headers, s, & header_line_vector);
    for (std::vector<std::string>::const_iterator it = header_line_vector.begin();
        it != header_line_vector.end(); ++it) {
            if (!it->empty())
                AddHeaderFromString(*it);
    }

}


void HttpRequestHeader::MergeFrom(const HttpRequestHeader& other) {
    for(base_logic::ListValue::iterator it = other.headers_->begin();
            it != other.headers_->end(); it++){
        HeaderKeyValuePair key_value((base_logic::DictionaryValue*)(*it));
        SetHeader(key_value.key(), key_value.value());        
    }
}

std::string HttpRequestHeader::ToString() const {
    std::string output;
    for (base_logic::ListValue::const_iterator it = headers_->begin();
        it != headers_->end(); it++) {
        HeaderKeyValuePair key_value((base_logic::DictionaryValue*)(*it));
        if (!key_value.value().empty())
            base::BasicUtil::StringUtil::StringAppendF(&output, "%s: %s\r\n",key_value.key().c_str(),
                    key_value.value().c_str());
        else
            base::BasicUtil::StringUtil::StringAppendF(&output, "%s\r\n",key_value.key().c_str());
    }

    output.append("\r\n");
    return output;
}

}
