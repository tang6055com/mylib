#ifndef PRODUCER_H_
#define PRODUCER_H_

#include <stdlib.h>
#include <string>
#include "rdkafka.h"  
#include "basic/basictypes.h"
#include "logic/base_values.h"
#include "basic/scoped_ptr.h"
#include "log/mig_log.h"

const int MAX_DATA_SIZE = 1024 * 1024;
const int PUSH_DATA_SUCCESS = 0;
const int PUSH_DATA_FAILED = -1;
const int INPUT_DATA_ERROR = -2;
const int FETCH_DATA_FAILED = -3;
const int PRODUCER_INIT_FAILED = -1;
const int PRODUCER_INIT_SUCCESS = 0;

typedef void(*MsgDelivered)(rd_kafka_t *rk,
							void *payload, size_t len,
							rd_kafka_resp_err_t error_code,
							void *opaque, void *msg_opaque);

class kafka_producer
{
public:
	kafka_producer();
	~kafka_producer();

	int Init(const int in_partition, const char* in_topic, const char* in_brokers, MsgDelivered in_func_msg_delivered);
	int PushData(const char* in_buf, const int in_buf_len);
	int PushData(base_logic::Value* in_data);
	void Close();
	int CheckState();

	static void Logger(const rd_kafka_t *rk, int level, const char *fac, const char *buf);
	static int state_;

private:
	int partition_;
	rd_kafka_conf_t *conf_;
	rd_kafka_topic_conf_t *topic_conf_;
	rd_kafka_t *rk_;
	rd_kafka_topic_t *rkt_;
	base_logic::ValueSerializer* engine_;
};

#endif