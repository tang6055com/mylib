#ifndef _MIG_FM_HTTP_API_H__
#define _MIG_FM_HTTP_API_H__

#include "logic/base_values.h"
#include "http/http_header.h"
namespace base_http{

class HttpAPI{
public:
	static bool RequestGetMethod(const std::string& url, 
                              base_logic::DictionaryValue* info,
			                  std::string& result, 
                              const int32 count = 3);

	static bool RequestPostMethod(const std::string& url,
                               base_logic::DictionaryValue* info,
			                    std::string& result,
                               const int32 count = 3);

    static bool RequestGetMethod(const std::string& url,
                                 base_logic::DictionaryValue* info,
                                 base_http::HttpRequestHeader* header,
                                 std::string& result,
                                 const int32 count = 3);


    static bool RequestPostMethod(const std::string& url,
                                 base_logic::DictionaryValue* info,
                                 base_http::HttpRequestHeader* header,
                                 std::string& result,
                                 const int32 count = 3);
private:
	static bool ParamSerialization(base_logic::DictionaryValue* info,std::string* content);
public:
	static base_logic::Value*  ResponseJsonSerialization(std::string* content);
	static base_logic::Value*  ResponseXmlSerializetion(std::string* content);

};

}
#endif
