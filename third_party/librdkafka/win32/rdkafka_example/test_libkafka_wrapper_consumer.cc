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
	printf("pull data:%s len:%d\n", data, data_len);
}

int main()
{
	char test_data[100];
	int partition = 0;
	strcpy(test_data, "helloworld");

	printf("test kafka wrapper consumer\n");

	wrapper_Info test_info;
	if (PRODUCER_INIT_SUCCESS == consumer_init(partition, "test2", "localhost:9092", &test_consume_data, &test_info))
		printf("consumer init success!\n");
	else
		printf("consumer init failed\n");

	while (fgets(test_data, sizeof(test_data), stdin)) {
		size_t len = strlen(test_data);
		if (test_data[len - 1] == '\n')
			test_data[--len] = '\0';
		if (strcmp(test_data, "end") == 0)
			break;
		memset(test_data, 0, sizeof(test_data));
		printf("begin receive data\n");
		if (PUSH_DATA_SUCCESS == consumer_pull_data(&test_info))
			printf("pull data success\n");
		else
			printf("pull data failed\n");
	}

	consumer_close(&test_info);

	return 0;
}
