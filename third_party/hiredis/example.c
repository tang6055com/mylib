#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hiredis.h"

int main(void) {
    unsigned int j;
    redisContext *c;
    redisReply *reply;

    struct timeval timeout = { 1, 500000 }; // 1.5 seconds
    c = redisConnectWithTimeout((char*)"127.0.0.1", 6379, timeout);
    if (c == NULL || c->err) {
        if (c) {
            printf("Connection error: %s\n", c->errstr);
            redisFree(c);
        } else {
            printf("Connection error: can't allocate redis context\n");
        }
        exit(1);
    }

    /* PING server */
    reply = redisCommand(c,"PING");
    printf("PING: %s\n", reply->str);
    freeReplyObject(reply);

    /* Set a key */
    reply = redisCommand(c,"SET %s %s", "foo", "hello world");
    printf("SET: %s\n", reply->str);
    freeReplyObject(reply);

    /* Set a key using binary safe API */
    reply = redisCommand(c,"SET %b %b", "bar", 3, "hello", 5);
    printf("SET (binary API): %s\n", reply->str);
    freeReplyObject(reply);

    /* Try a GET and two INCR */
    reply = redisCommand(c,"GET foo");
    printf("GET foo: %s\n", reply->str);
    freeReplyObject(reply);

    reply = redisCommand(c,"INCR counter");
    printf("INCR counter: %lld\n", reply->integer);
    freeReplyObject(reply);
    /* again ... */
    reply = redisCommand(c,"INCR counter");
    printf("INCR counter: %lld\n", reply->integer);
    freeReplyObject(reply);

    /* Create a list of numbers, from 0 to 9 */
    reply = redisCommand(c,"DEL mylist");
    freeReplyObject(reply);
    for (j = 0; j < 10; j++) {
        char buf[64];

        snprintf(buf,64,"%d",j);
        reply = redisCommand(c,"LPUSH mylist element-%s", buf);
        freeReplyObject(reply);
    }

    /* Let's check what we have inside the list */
    reply = redisCommand(c,"LRANGE mylist 0 -1");
    if (reply->type == REDIS_REPLY_ARRAY) {
        for (j = 0; j < reply->elements; j++) {
            printf("%u %s\n", j, reply->element[j]->str);
        }
    }

	printf("len[%d] integer[%lld] element[%ld]\n",reply->len,reply->integer,reply->elements);
    
	freeReplyObject(reply);
    const char* hash_name1 = "mm_r1";
	const char* value1 = "1";
	const char* value2 = "2";
	const char* value3 = "3";
	reply = redisCommand(c,"hmget %s %s %s %s",hash_name1,value1,value2,value3);
	
	printf("len[%d] integer[%lld] element[%ld]\n",reply->len,reply->integer,reply->elements);

	if(reply->type==REDIS_REPLY_ARRAY){
		for(j = 0;j<reply->elements;j++){
			printf("element->str[%s]\n",reply->element[j]->str);
		}
	}
    const char* song_value1 = "515518";
	const char* song_value2 = "515519";
	const char* song_value3 = "515520";
    const char* song_value4 = "mget 515518 515519 515520";
    printf("=====================================\n");
	reply = redisCommand(c,song_value4);
	//reply = redisCommand(c,"mget 515518 515519 515520");
	printf("reply len[%d] integer[%lld] element[%ld]\n",reply->len,reply->integer,reply->elements);
	
	if(reply->type==REDIS_REPLY_ARRAY){
		for(j = 0;j<reply->elements;j++){
			printf("reply element->str[%s]\n",reply->element[j]->str);
		}
	}
	char tkeys[256] = "h10382clt";
	reply = redisCommand(c,"hgetall %s",tkeys);
	printf("reply->elemets %ld",reply->elements);
	if(reply->type==REDIS_REPLY_ARRAY){
		for(j=0;j<reply->elements;j++){
	        printf("reply element->str[%s]\n",reply->element[j]->str);		
		}
	}
	getchar();
    return 0;
}
