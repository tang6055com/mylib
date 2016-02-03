#ifndef CONSUMER_H_
#define CONSUMER_H_

#include <ctype.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <syslog.h>
#include <sys/time.h>
#include <errno.h>

#include "rdkafka.h"  
#include "basic/basictypes.h"
#include "logic/base_values.h"
#include "basic/scoped_ptr.h"
#include "log/mig_log.h"
#include <limits>
#include <string>

#define CONSUMER_INIT_FAILED -1
#define CONSUMER_INIT_SUCCESS 0
#define PULL_DATA_SUCCESS 0
#define PULL_DATA_FAILED 1
#define PULL_DATA_TIMEOUT 2

typedef void(*MsgConsume)(rd_kafka_message_t *rkmessage, void *opaque);

class Consumer
{
public:

	int Init(const int in_partition, const char* in_topic, const char* in_brokers, MsgConsume msg_consume);
	int PullData(std::string& out_data);
	int PullDataCallback();
	int PullDataAndDeserialize(base_logic::Value* &out_value, int& out_error_code, std::string& out_error_str);
	void Close();

	Consumer();
	~Consumer();

private:
	int partition_;
	rd_kafka_t *rk_;
	rd_kafka_topic_t *rkt_;
	MsgConsume msg_consume_;
};

#endif