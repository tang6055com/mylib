#ifndef CONSUMER_H_
#define CONSUMER_H_

#include <stdlib.h>
#include <string>
#include <list>
#include "rdkafka.h"
#include "config/config.h"
#include "basic/basictypes.h"
#include "logic/base_values.h"
#include "logic/logic_comm.h"
#include "basic/scoped_ptr.h"
#include "log/mig_log.h"

const int CONSUMER_INIT_FAILED = -1;
const int CONSUMER_INIT_SUCCESS = 0;
const int CONSUMER_CONFIG_ERROR = 3;
const int PULL_DATA_SUCCESS = 0;
const int PULL_DATA_FAILED = -1;
const int PULL_DATA_TIMEOUT = 2;
const int PULL_DATA_DATA_NULL = -4;
const size_t MAX_MSG_NUM_PER_TIME = 80;

typedef void(*MsgConsume)(rd_kafka_message_t *rkmessage, void *opaque);

class kafka_consumer
{
public:
	kafka_consumer();
	~kafka_consumer();

	int Init (base::ConnAddr& addr);
	int Init(const int in_partition, const char* in_topic, const char* in_brokers, MsgConsume msg_consume);
	int PullData(std::string& out_data);
	int PullDataBatch(std::list<std::string>* list);
	int PullDataCallback();
	int PullDataAndDeserialize(base_logic::Value* &out_value, int& out_error_code, std::string& out_error_str);
	void Close();

private:
	int partition_;
	rd_kafka_t *rk_;
	rd_kafka_topic_t *rkt_;
	MsgConsume msg_consume_;
};

#endif
