//  Copyright (c) 2012-2017 The MIGLIB Authors. All rights reserved.
//  Created on: 2017年6月18日 Author: kerry


#include "http/http_util.h"
#include <string.h>
#define HTTP_LWS " \t"

namespace base_http {

void HttpUtil::TrimLWS(std::string::const_iterator* begin,
                       std::string::const_iterator* end) {

    while (*begin < *end && IsLWS((*begin)[0]))
        ++(*begin);

    while(*begin < *end && IsLWS((*end)[-1]))
        ++(*end);
}

bool HttpUtil::IsLWS(char c) {
    return strchr(HTTP_LWS, c) != NULL;
}


}
