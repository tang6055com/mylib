#include "Producer.h"


Producer::Producer()
{
}


Producer::~Producer()
{
}


int Producer::Init(const int partition, const char* topic, const char* brokers, Msg_Delivered func_msg_delivered)
{
	char errstr[512];

	conf_ = rd_kafka_conf_new();
	topic_conf_ = rd_kafka_topic_conf_new();

	if (RD_KAFKA_CONF_OK != rd_kafka_conf_set(conf_, "message.max.bytes", "1024 * 1024", NULL, 0))
		return PRODUCER_INIT_FAILED;
	if (RD_KAFKA_CONF_OK != rd_kafka_conf_set(conf_, "queue.buffering.max.messages", "500000", NULL, 0))
		return PRODUCER_INIT_FAILED;
	if (RD_KAFKA_CONF_OK != rd_kafka_conf_set(conf_, "queued.min.messages", "1000000", NULL, 0))
		return PRODUCER_INIT_FAILED;
	if (RD_KAFKA_CONF_OK != rd_kafka_conf_set(conf_, "message.send.max.retries", "1", NULL, 0))
		return PRODUCER_INIT_FAILED;
	if (RD_KAFKA_CONF_OK != rd_kafka_conf_set(conf_, "retry.backoff.ms", "500", NULL, 0))
		return PRODUCER_INIT_FAILED;
	if (RD_KAFKA_CONF_OK != rd_kafka_conf_set(conf_, "compression.codec", "snappy", NULL, 0))
		return PRODUCER_INIT_FAILED;

	if (NULL != func_msg_delivered)
		rd_kafka_conf_set_dr_cb(conf_, func_msg_delivered);

	if (!(rk_ = rd_kafka_new(RD_KAFKA_PRODUCER, conf_,
		errstr, sizeof(errstr)))) {
		fprintf(stderr,
			"%% Failed to create new producer: %s\n",
			errstr);
		return PRODUCER_INIT_FAILED;
	}

	if (rd_kafka_brokers_add(rk_, brokers) == 0) {
		fprintf(stderr, "%% No valid brokers specified\n");
		return PRODUCER_INIT_FAILED;
	}

	rkt_ = rd_kafka_topic_new(rk_, topic, topic_conf_);

	return PRODUCER_INIT_SUCCESS;
}

int Producer::PushData(const char* buf, const int buf_len)
{
	int produce_ret;
	if (NULL == buf)
		return 0;
	if (0 == buf_len || buf_len > MAX_DATA_SIZE)
		return -1;

	printf("118producer->partition:%d\n", partition_);
	/* Send/Produce message. */
	produce_ret = rd_kafka_produce(rkt_, partition_,
		RD_KAFKA_MSG_F_COPY,
		/* Payload and length */
		(void*)buf, (size_t)buf_len,
		/* Optional key and its length */
		NULL, 0,
		/* Message opaque, provided in
		* delivery report callback as
		* msg_opaque. */
		NULL);
	printf("129produce_ret = %d\n", produce_ret);
	if (produce_ret == -1) {
		fprintf(stderr,
			"%% Failed to produce to topic %s "
			"partition %i: %s\n",
			rd_kafka_topic_name(rkt_), partition_,
			rd_kafka_err2str(
			rd_kafka_errno2err(errno)));
		/* Poll to handle delivery reports */
		rd_kafka_poll(rk_, 0);
		return PUSH_DATA_FAILED;
	}

	fprintf(stderr, "136%% Sent %d bytes to topic "
		"%s partition %i\n",
		buf_len, rd_kafka_topic_name(rkt_), partition_);
	/* Poll to handle delivery reports */
	rd_kafka_poll(rk_, 0);
	return PUSH_DATA_SUCCESS;
}

int Producer::PushData(base_logic::Value* data)
{
	std::string json_str;
	base_logic::ValueSerializer* engine = base_logic::ValueSerializer::Create(0, &json_str);
	engine->Serialize(*data);
	return PushData(json_str.c_str(), json_str.size());
}

void Producer::Close()
{
	rd_kafka_topic_destroy(this->rkt_);
	rd_kafka_destroy(this->rk_);
}
