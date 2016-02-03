#include "Producer.h"




int main()
{
	char test_data[100];
	strcpy(test_data, "helloworld");

	Producer* producer = new Producer;
	if (PRODUCER_INIT_SUCCESS == producer->Init(0, "test2", "localhost:9092", NULL))
	{
		printf("producer init success\n");
	}
	else
	{
		printf("producer init failed\n");
		return 0;
	}
	
	while (fgets(test_data, sizeof(test_data), stdin)) {
		size_t len = strlen(test_data);
		if (test_data[len - 1] == '\n')
			test_data[--len] = '\0';
		if (strcmp(test_data, "end") == 0)
			break;
		if (PUSH_DATA_SUCCESS == producer->PushData(test_data, strlen(test_data)))
			printf("push data success %s\n", test_data);
		else
			printf("push data failed %s\n", test_data);
	}

	producer->Close();
	
	return 0;
}