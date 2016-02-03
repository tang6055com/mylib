#include "Consumer.h"


int main()
{
	std::string test_data_str;
	char test_data[100];

	Consumer* consumer = new Consumer;
	if (CONSUMER_INIT_SUCCESS == consumer->Init(0, "test2", "localhost:9092", NULL))
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
		if (PULL_DATA_SUCCESS == consumer->PullData(test_data_str))
			printf("push data success %s\n", test_data_str.c_str());
		else
			printf("push data failed \n");
	}

	consumer->Close();
	return 0;
}