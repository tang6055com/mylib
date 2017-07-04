//  Copyright (c) 2015-2016 The kid Authors. All rights reserved.
//   Created on: 2016.12.23 Author: kerry

#include "gtest/gtest.h"
#include "build/build_config.h"
#include "logic/logic_comm.h"
#include "basic/basictypes.h"
#include "log/mig_log.h"
#include "logic/base_values.h"
#include "basic/radom_in.h"
#include "http/http_header.h"
#include <string>

class ValueTest: public testing::Test {
};

#include <ctype.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <syslog.h>
#include <sys/time.h>
#include <errno.h>
//#include "rdkafka.h"
#include "logic/base_values.h"


TEST(ValueTest, Basic){
    double b = 10000.23131;
    std::string body_stream;
    base_logic::DictionaryValue* t  = new base_logic::DictionaryValue();
    t->SetReal(L"b",b);
    base_logic::ValueSerializer *engine 
                = base_logic::ValueSerializer::Create(base_logic::IMPL_JSON);
    base_logic::Value* value = (base_logic::Value*)(t);
    engine->Serialize((*value), &body_stream);

    printf("%s",body_stream.c_str());
}
