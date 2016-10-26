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
void TransmissionTemplateDemo(TransmissionTemplate* templ);

// http的域名
//static char *host ="http://sdk.open.api.igexin.com/apiex.htm";

//https的域名
static char *host ="https://api.getui.com/apiex.htm";

//定义常量, appId、appKey、masterSecret 采用本文档 "第二步 获取访问凭证 "中获得的应用配置
static char *appId = "TxzlIyCcfS9KuENjjP4ux1";            
static char *appKey = "rAnoicfrNX7915IxPocAL2";           
static char *masterSecret = "KFDNBNKAVj9bgykwvqgeA5";  
static char *cid = "e605a0db5ce3cca9b76b012978064940"; 

void toapptest();

void toapptest(){

    // 定义"AppMessage"类型消息对象，设置消息内容模板、发送的目标App列表、是否支持离线发送、以及离线消息有效期(单位毫秒)
    Message msg = {0};
    msg.isOffline = 0;//是否离线下发
    msg.offlineExpireTime = 1000*3600*2;//离线下发有效期 毫秒
    msg.pushNetWorkType = 0;//0不限 1wifi 2:4G/3G/2G

    AppMessage appMsg = {0};
    appMsg.msg = msg;
        appMsg.speed = 10000;//定速
    char* appList[] = {appId};
    appMsg.appIdList = appList;
    appMsg.appIdListSize = 1;

    IPushResult result = {0};
    //透传模板,设置透传内容和透传形式
    TransmissionTemplate tmpl= {0};
        TransmissionTemplateDemo(& tmpl);
    result = pushMessageToApp(appKey, &appMsg, &tmpl, Transmission);
    //打印结果
    printResult(result);
}

/*  透传消息模板  */
void TransmissionTemplateDemo(TransmissionTemplate* templ)
{
    templ->t.appId = appId;
    templ->t.appKey = appKey;
     //应用启动类型，1：强制应用启动 2：等待应用启动
    templ->transmissionType = 1;          
    //透传内容  
    templ->transmissionContent = "您输入的透传内容";

    //templ->t.duration_start="2015-07-10 18:00:00";
    //templ->t.duration_end="2015-07-10 19:00:00";
} 

static void printResult(IPushResult &result) {
    cout << "print result:-------------" << endl;
    for (int i = 0; i < result.size; i++) {
        cout << result.entry[i].key << ": " << result.entry[i].value << endl;
    }
    cout << "print end:----------------" << endl;
}

int main5(){
    // 注意：接口传入字符必须为UTF-8编码，因ASCII字符UTF－8编码后与原先一样，所以可以不编码，但中文等非ASCII字符必须编码
    // 如果返回的类似错误"post http data failed, code=6"
    //错误码可百度CURL返回的错误码是什么意思，如http: www.cnblogs.com/wainiwann/p/3492939.html
    Result r = pushInit(host, appKey, masterSecret, "编码");//"编码"两个字为固定写法，不需要做转换
    if(r!=SUCCESS){
        printf("pushInit for app failed: ret=%d\n", r);
        return -1;
    }
    toapptest();
    return 0;
}