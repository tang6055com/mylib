#ifndef PRODUCER_H_
#define PRODUCER_H_

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

#define MAX_DATA_SIZE 1024 * 1024
#define PUSH_DATA_SUCCESS 0
#define PUSH_DATA_FAILED -1
#define PRODUCER_INIT_FAILED -1
#define PRODUCER_INIT_SUCCESS 0

typedef void(*Msg_Delivered)(rd_kafka_t *rk,
	void *payload, size_t len,
	rd_kafka_resp_err_t error_code,
	void *opaque, void *msg_opaque);

class Producer
{
public:
	Producer();
	~Producer();

	int Init(const int in_partition, const char* in_topic, const char* in_brokers, Msg_Delivered in_func_msg_delivered);
	int PushData(const char* in_buf, const int in_buf_len);
	int PushData(base_logic::Value* in_data);
	void Close();


private:
	int partition_;
	rd_kafka_conf_t *conf_;
	rd_kafka_topic_conf_t *topic_conf_;
	rd_kafka_t *rk_;
	rd_kafka_topic_t *rkt_;
	base_logic::ValueSerializer* engine_;
};

#endif