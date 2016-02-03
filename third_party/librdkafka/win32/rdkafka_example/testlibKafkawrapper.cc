#include "KafkaWrapper.h"

void test_msg_delivered(rd_kafka_t *rk,
	void *payload, size_t len,
	rd_kafka_resp_err_t error_code,
	void *opaque, void *msg_opaque)
{
	printf("8test_msg_delivered\n");
}

void test_consume_data(const char* data, const int data_len)
{

}

int main()
{
	char test_data[100];
	int topic = 0;
	strcpy(test_data, "helloworld");

	printf("test kafka wrapper\n");

	wrapper_Info test_info;
	if (PRODUCER_INIT_SUCCESS == producer_init(topic, "test2", "localhost:9092", &test_msg_delivered, &test_info))
		printf("producer init success!\n");
	else
		printf("producer init failed\n");

	while (fgets(test_data, sizeof(test_data), stdin)) {
		size_t len = strlen(test_data);
		if (test_data[len - 1] == '\n')
			test_data[--len] = '\0';
		if (strcmp(test_data, "end") == 0)
			break;
		if (PUSH_DATA_SUCCESS == producer_push_data(test_data, strlen(test_data), &test_info))
			printf("push data success %s\n", test_data);
		else
			printf("push data failed %s\n", test_data);
	}

	producer_close(&test_info);

	return 0;
}
