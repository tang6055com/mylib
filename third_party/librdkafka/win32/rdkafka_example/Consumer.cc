#include "Consumer.h"


Consumer::Consumer()
{
}


Consumer::~Consumer()
{
}

int Consumer::Init(const int partition, const char* topic, const char* brokers, MsgConsume msg_consume)
{
	char err_str[512];
	partition_ = partition;
	msg_consume_ = msg_consume;

	rd_kafka_conf_t *conf = rd_kafka_conf_new();
	if (NULL == conf)
		return CONSUMER_INIT_FAILED;
	if (RD_KAFKA_CONF_OK != rd_kafka_conf_set(conf, "group.id", "one", err_str, sizeof(err_str)))
		return CONSUMER_INIT_FAILED;

	rd_kafka_conf_set(conf, "queued.min.messages", "1000000", NULL, 0);

	if (!(rk_ = rd_kafka_new(RD_KAFKA_CONSUMER, conf,
		err_str, sizeof(err_str)))) {
		fprintf(stderr,	"%% Failed to create new consumer: %s\n",err_str);
		return CONSUMER_INIT_FAILED;
	}
	rd_kafka_set_log_level(rk_, LOG_ERR);
	if (rd_kafka_brokers_add(rk_, brokers) == 0) {
		fprintf(stderr, "%% No valid brokers specified\n");
		return CONSUMER_INIT_FAILED;
	}
	rd_kafka_topic_conf_t *topic_conf = rd_kafka_topic_conf_new();

	rkt_ = rd_kafka_topic_new(rk_, topic, topic_conf);
	if (rd_kafka_consume_start(this->rkt_, partition, RD_KAFKA_OFFSET_END) == -1){
		fprintf(stderr, "%% Failed to start consuming: %s\n", rd_kafka_err2str(rd_kafka_errno2err(errno)));
		return CONSUMER_INIT_FAILED;
	}

	return CONSUMER_INIT_SUCCESS;
}

int Consumer::PullData(std::string& data)
{
	rd_kafka_message_t *rkmessage;
	int consume_result = PULL_DATA_SUCCESS;

	printf("217consumer_info->rk:%p, rkt:%p, partition=%d\n", rk_, rkt_, partition_);
	printf("217 begin poll\n");
	rd_kafka_poll(rk_, 0);
	printf("219begin consume\n");
	rkmessage = rd_kafka_consume(rkt_, partition_, 1000);
	if (!rkmessage) 
		return PULL_DATA_TIMEOUT;

	if (rkmessage->err) {
		if (rkmessage->err == RD_KAFKA_RESP_ERR__PARTITION_EOF) {
			consume_result = PULL_DATA_SUCCESS;
		}
		if (rkmessage->err == RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION ||
			rkmessage->err == RD_KAFKA_RESP_ERR__UNKNOWN_TOPIC)
			return rkmessage->err;
		consume_result = PULL_DATA_FAILED;
	}
	data = std::string((const char*)rkmessage->payload, rkmessage->len);
	rd_kafka_message_destroy(rkmessage);

	return consume_result;
}

void Consumer::Close()
{
	rd_kafka_consume_stop(rkt_, partition_);

	while (rd_kafka_outq_len(rk_) > 0)
		rd_kafka_poll(rk_, 10);

	rd_kafka_topic_destroy(rkt_);

	rd_kafka_destroy(rk_);
}

int Consumer::PullDataAndDeserialize(base_logic::Value* &value, int& error_code, std::string& error_str)
{
	std::string data;
	int pull_result = PullData(data);
	if (PULL_DATA_SUCCESS == pull_result)
	{
		base_logic::ValueSerializer* engine = base_logic::ValueSerializer::Create(0, &data);
		value = engine->Deserialize(&error_code, &error_str);
	}
	return pull_result;
}

int Consumer::PullDataCallback()
{
	int int_return = rd_kafka_consume_callback(rkt_, partition_,
		1000,
		msg_consume_,
		NULL);

	if (int_return == -1)
		return PULL_DATA_FAILED;

	rd_kafka_poll(rk_, 0);

	return PULL_DATA_SUCCESS;
}

