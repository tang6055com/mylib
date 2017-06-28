//  Copyright (c) 2012-2017 The MIGLIB Authors. All rights reserved.  
//  Created on: 2017年6月18日 Author: kerry
#ifndef _MIG_BASIC_HTTP_HTTP_HEADER_H__
#define _MIG_BASIC_HTTP_HTTP_HEADER_H__

#include "logic/base_values.h"
#include "basic/scoped_ptr.h"

namespace base_http {

class HttpRequestHeader{
 public:
    class  HeaderKeyValuePair{
      public:
        HeaderKeyValuePair() 
        :dictionary_(NULL){
            dictionary_ = new base_logic::DictionaryValue();
        }

        HeaderKeyValuePair(const std::string& key, const std::string& value){
            dictionary_ = new base_logic::DictionaryValue();
            dictionary_->SetString(L"key", key);
            dictionary_->SetString(L"value", value);
        }

        HeaderKeyValuePair(base_logic::DictionaryValue* dictionary) {
            dictionary_ = new base_logic::DictionaryValue();
            std::string key;
            std::string value;
            dictionary->GetString(L"key", &key);
            dictionary->GetString(L"value", &value);
            dictionary_->SetString(L"key", key);
            dictionary_->SetString(L"value", value);
        }

        base_logic::DictionaryValue* Get(){
            return dictionary_;
        }

        std::string key() const {
            std::string key;
            bool r = dictionary_->GetString(L"key", &key);
            return key;
        }

        std::string value() const {
            std::string value;
            bool r = dictionary_->GetString(L"value", &value);
            return value;
        }

        void AddValue(const std::string& value, const std::string& separator){
            std::string v;
            v = v + separator + value;
            dictionary_->SetString(L"value", v);
        }

        void SetValue(const std::string& value) {
            dictionary_->SetString(L"value", value);
        }
    private:
        base_logic::DictionaryValue*  dictionary_;
    };

    static const char kGetMethod[];
    static const char kAcceptCharset[];
    static const char kAcceptEncoding[];
    static const char kAcceptLanguage[];
    static const char kCacheControl[];
    static const char kConnection[];
    static const char kContentType[];
    static const char kContentLength[];
    static const char kCookie[];
    static const char kHost[];
    static const char kIfModifiedSince[];
    static const char kIfNoneMatch[];
    static const char kIfRange[];
    static const char kOrigin[];
    static const char kPragma[];
    static const char kProxyConnection[];
    static const char kRange[];
    static const char kReferer[];
    static const char kUserAgent[];

    HttpRequestHeader();
    ~HttpRequestHeader();

    bool IsEmpty() const {return headers_->empty();}

    bool HasHeader(const std::string& key) {
        return FindHeaderConst(key) != headers_->end();
    }

    bool GetHeader(const std::string& key, std::string* out);

    void Clear();

    void SetHeader(const std::string& key, const std::string& value);

    void RemoveHeader(const std::string& key);

    void AddHeaderFromString(const std::string& header_line);

    void AddHeadersFromString(const std::string& headers);

    void MergeFrom(const HttpRequestHeader& other);

    void CopyFrom(const HttpRequestHeader& other){
        *this = other;
    }

    std::string ToString() const;
 private:
    base_logic::ListValue::iterator FindHeader(const std::string& key);
    base_logic::ListValue::const_iterator FindHeaderConst(const std::string& key);
 private:
    base_logic::ListValue*   headers_;
};


class HttpReponseHeader{

};
}

#endif
