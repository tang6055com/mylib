#include "IGtPush.h"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#ifdef WIN32
#include <windows.h>
#endif

using namespace std;
static void printResult(IPushResult &result);
static void printQueryResult(IQueryResult &result);


void bindAliastest();


void bindAliasListtest();


void queryClientIdtest();


void stopTaskTest();


void getresult();


void getInfo();


static char *host ="http://sdk.open.api.getui.net/apiex.htm";

static char *appId = "";
static char *appKey = "";
static char *masterSecret = "";
static char *cid = "";
static char *cid1 = "";

void bindAliastest(){
    IPushResult result = bindAlias(appKey, appId, "test", cid);
    printResult(result);
}

void bindAliasListtest(){
    Target* targetList = new Target[2];
    targetList[0].clientId = cid;
    targetList[0].alias = "test";

    targetList[1].clientId = cid1;
    targetList[1].alias = "test";

    IPushResult result = bindAliasList(appKey, appId, targetList, 2);
    printResult(result);
    delete []targetList;
}

void queryClientIdtest() {
    char* list = NULL;
    IPushResult result = queryClientId(appKey, appId, "test", &list);

    printResult(result);

    if(list != NULL) {
        cout << "cidlist:" << list<<endl;

        releaseMem(list);
    }
}


void queryAliastest(){
        IPushResult result = queryAlias(appKey, appId, cid);
        printResult(result);
}

void unBindAliastest() {
        IPushResult result = unBindAlias(appKey, appId, "test", cid);
        printResult(result);
}

void unBindAliasAlltest() {
        IPushResult result = unBindAliasAll(appKey, appId, "test");
        printResult(result);
}
void stopTaskTest() {
        Result result = pushStop(appKey,"OSA-0614_UMyJntaHJPAuDdq1M3dns");
        printf("%d\n", result);
}

void getuserinfo(){
    IQueryResult result = {0};
    result = queryAppUserDataByDate(appKey,appId,"20150910");
    printQueryResult(result);
}

void getappinfo(){
        IQueryResult result = {0};
        result = queryAppPushDataByDate(appKey,appId,"20150910");
        printQueryResult(result);
}

void getresult(){

        IPushResult result = {0};
        result = getPushResult(appKey,"OSL-0911_bN5foZPGSR6ddDPkWs8XQ5");
        printResult(result);
}

static void printResult(IPushResult &result) {
    cout << "print result:-------------" << endl;
    for (int i = 0; i < result.size; i++) {
        cout << result.entry[i].key << ": " << result.entry[i].value << endl;
    }
    cout << "print end:----------------" << endl;
}

static void printQueryResult(IQueryResult &result) {
    cout << "print result:-------------" << endl;
    cout <<"result:"<<result.result<<endl;
    for (int i = 0; i < result.size; i++) {
        cout << result.data[i].key << ": " << result.data[i].value << endl;
    }
    cout << "print end:----------------" << endl;
}

int main(){
	 // 注意：接口传入字符必须为UTF-8编码，因ASCII字符UTF－8编码后与原先一样，所以可以不编码，但中文等非ASCII字符必须编码
    // 如果返回的类似错误"post http data failed, code=6"
    //错误码可百度CURL返回的错误码是什么意思，如http: www.cnblogs.com/wainiwann/p/3492939.html
    Result r = pushInit(host, appKey, masterSecret, "编码");
    if(r!=SUCCESS){
        printf("pushInit for app failed: ret=%d\n", r);
        return -1;
    }

    //bindAliastest();
    //bindAliasListtest();
    //queryClientIdtest();
    //unBindAliastest();
    //queryAliastest();
    //unBindAliasAlltest();

    //getuserinfo();
    //getappinfo();
    //getresult();
    stopTaskTest();
    return 0;
}
