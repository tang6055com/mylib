/*
 * http_api.cc
 *
 *  Created on: 2015年5月8日
 *      Author: pro
 */
#include "http_api.h"
#include "logic/logic_comm.h"
#include "logic/http_serializer.h"
#include "http/http_method.h"
#include "basic/scoped_ptr.h"

namespace base_http{


bool HttpAPI::RequestGetMethod(const std::string& url, 
                                base_logic::DictionaryValue* info,
                                base_http::HttpRequestHeader* header,
                                std::string& result,
                                const int32 count ) {

	std::string content;
	bool r = ParamSerialization(info,&content);
	if(!r)
		return false;
	std::string query = url+std::string("?")+content;
	http::HttpMethodGet http(query);
    std::string header_line = header->ToString();
    http.SetHeaders(header_line);
	int32 i = 0;
	do{
		r = http.Get();
		if(r)
			break;
		i++;
		if(i>=count)
			break;

	}while(true);

	if(!r)
		return false;
	r = http.GetContent(result);
	if(!r)
		return r;
	return true;
}

bool HttpAPI::RequestPostMethod(const std::string& url,
                                base_logic::DictionaryValue* info,
                                base_http::HttpRequestHeader* header,
                                std::string& result,
                                const int32 count){	
    std::string content;
	bool r = ParamSerialization(info,&content);
	if(!r)
		return false;
	http::HttpMethodPost http(url);
    std::string header_line = header->ToString();
    http.SetHeaders(header_line);
	int32 i = 0;
	do{
		r = http.Post(content.c_str());
		if(r)
			break;
		i++;
		if(i>=count)
			break;

	}while(true);

	if(!r)
		return false;
	r = http.GetContent(result);
	if(!r)
		return r;
	return true;
}


bool HttpAPI::RequestGetMethod(const std::string& url,base_logic::DictionaryValue* info,
		std::string& result,const int32 count){

    LOG_MSG("Please stop function");
	std::string content;
	bool r = ParamSerialization(info,&content);
	if(!r)
		return false;
	std::string query = url+std::string("?")+content;
	http::HttpMethodGet http(query);
    std::string  headers = "Authorization:APPCODE e361298186714a6faea52316ff1d5c32";
    http.SetHeaders(headers);
	int32 i = 0;
	do{
		r = http.Get();
		if(r)
			break;
		i++;
		if(i>=count)
			break;

	}while(true);

	if(!r)
		return false;
	r = http.GetContent(result);
	if(!r)
		return r;
	return true;
}


bool HttpAPI::RequestPostMethod(const std::string& url,base_logic::DictionaryValue* info,
		std::string& result,const int32 count){	
    LOG_MSG("Please stop function");
    std::string content;
	bool r = ParamSerialization(info,&content);
	if(!r)
		return false;
	http::HttpMethodPost http(url);
	int32 i = 0;
	do{
		r = http.Post(content.c_str());
		if(r)
			break;
		i++;
		if(i>=count)
			break;

	}while(true);

	if(!r)
		return false;
	r = http.GetContent(result);
	if(!r)
		return r;
	return true;
}

bool HttpAPI::ParamSerialization(base_logic::DictionaryValue* info,std::string* content){
	 scoped_ptr<base_logic::ValueSerializer> engine(base_logic::ValueSerializer::Create(base_logic::IMPL_HTTP,content));
	 base_logic::Value* value = (base_logic::Value*)info;
	 return engine->Serialize(*value);
}

base_logic::Value* HttpAPI::ResponseJsonSerialization(std::string* content){
	std::string error_str;
	int error_code = 0;
	scoped_ptr<base_logic::ValueSerializer>engine(base_logic::ValueSerializer::Create(base_logic::IMPL_JSON,content));
	return engine->Deserialize(&error_code,&error_str);
}

base_logic::Value* ResponseXmlSerializetion(std::string* content){
	std::string error_str;
	int error_code = 0;
	scoped_ptr<base_logic::ValueSerializer> engine(base_logic::ValueSerializer::Create(base_logic::IMPL_XML,content));
	return engine->Deserialize(&error_code,&error_str);
}

}



