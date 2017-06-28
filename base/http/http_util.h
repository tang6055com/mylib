//  Copyright (c) 2012-2017 The MIGLIB Authors. All rights reserved.  
//  Created on: 2017年6月18日 Author: kerry


#ifndef _MIG_BASIC_HTTP_HTTP_UTIL_H__
#define _MIG_BASIC_HTTP_HTTP_UTIL_H__
#include <string>
namespace base_http {
class HttpUtil {
 public:
    static void TrimLWS(std::string::const_iterator* begin,
                        std::string::const_iterator* end);

    static bool IsLWS(char c);
};

}
#endif
