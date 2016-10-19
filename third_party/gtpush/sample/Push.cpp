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
static void TransmissionTemplateDemo(TransmissionTemplate* templ);

//https的域名
static char *host ="http://sdk.open.api.getui.net/apiex.htm";

//定义常量, appId、appKey、masterSecret 采用本文档 "第二步 获取访问凭证 "中获得的应用配置
static char *appId = "d2YVUlrbRU6yF0PFQJfPkA";
static char *appKey = "yEIPB4YFxw64Ag9yJpaXT9";
static char *masterSecret = "bMsRgf7RrA6jBG4sNbv0F6";
static char *cid = "86c4a1aedf2c6332815df96a8c0ae8f53d5263b231241d576e9620722150fb92";              //要推送用户的cid
static char *dt="86c4a1aedf2c6332815df96a8c0ae8f53d5263b231241d576e9620722150fb92";                 //IOS设备唯一标识号

//用于群推
static char *cid1 = "";              //要推送用户的cid
//static char *alais=""; //要推送用户的别名

void tosingletest();

void tosingletest(){

    //准备数据
    Message msg = {0};
    msg.isOffline = true;//是否离线下发
    msg.offlineExpireTime = 1000*3600*2;//离线下发有效期 毫秒
    msg.pushNetWorkType = 0;//0不限 1wifi 2:4G/3G/2G
    SingleMessage singleMsg = {0};
    singleMsg.msg = msg;

    //目标用户
    Target target = {0};
    target.appId = appId;
    target.clientId = cid;
    //target.alias = "个推1";
    IPushResult result = {0};


    TransmissionTemplate tmpl= {0};
  TransmissionTemplateDemo(& tmpl);
    result = pushMessageToSingle(appKey, &singleMsg, &tmpl, Transmission, &target);

    printResult(result);
}

void tolisttest();

void tolisttest(){

    //准备数据
    Message msg = {0};
    msg.isOffline = true;//是否离线下发
    msg.offlineExpireTime = 1000*3600*2;//离线下发有效期 毫秒
    msg.pushNetWorkType = 0;//0不限 1wifi 2:4G/3G/2G
    ListMessage listMsg = {0};
    listMsg.msg = msg;


    TransmissionTemplate tmpl= {0};
    TransmissionTemplateDemo(& tmpl);
    Result ret;
    char contentId[50] = "";
    ret = getContentId(appKey, &listMsg, &tmpl, Transmission, contentId, sizeof(contentId));


    if (ret == SUCCESS) {
        Target* targetList = new Target[2];
        memset((void*)targetList, 0, sizeof(Target));
        targetList[0].appId = appId;
        targetList[0].clientId = cid;
       // targetList[0].alias = "alias";
        targetList[1].appId = appId;
        targetList[1].clientId = cid1;
       // targetList[1].alias = "bbb";

        PushDetail details[2] = {0};

        //cout << "============pushMessageToList============" << endl;
        IPushResult result = {0};
        result = pushMessageToList(appKey, contentId, targetList,2, details);
        cout<<details->cid<<","<<details->ret<<endl;
        printResult(result);

        ret = cancelContentId(appKey, contentId);
        cout << "cancelContentId ret=" << ret << endl;
    }

}

void toapptest1();

void toapptest1(){

    //准备数据
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
    //透传模板
    TransmissionTemplate tmpl= {0};
        TransmissionTemplateDemo(& tmpl);
    result = pushMessageToApp(appKey, &appMsg, &tmpl, Transmission);
    //打印结果
    printResult(result);
}

void toapnsingletest();

void toapnlisttest();

//apn群推
void toapnlisttest(){

    //准备数据
    Message msg = {0};
    msg.isOffline = 1;//是否离线下发
    msg.offlineExpireTime = 1000*3600*2;//离线下发有效期 毫秒
    ListMessage listMsg = {0};
    listMsg.msg = msg;

    //模板
    //IOS自定义消息
    Entry cmsg = {0};
    strcpy(cmsg.key,"cmsg");
    strcpy(cmsg.value,"cmsg");

    //title-loc-args赋值
    ListItem titlelocargs[2]={"titlelocargs1","titlelocargs2"};

    //locargs赋值
    ListItem locargs[2]={"locargs1","locargs2"};

    //APN推送模板，只包含了父类模板
    APNTemplate templ = {0};
    templ.t.appId = appId;
    templ.t.appKey = appKey;

    templ.t.pushInfo.badge=4;
    templ.t.pushInfo.sound="";
    templ.t.pushInfo.contentAvailable=1;
    templ.t.pushInfo.category="";
    templ.t.pushInfo.cmsg.size=1;
    templ.t.pushInfo.cmsg.map = &cmsg;

    templ.t.pushInfo.body="body";
    templ.t.pushInfo.actionLocKey="";

    templ.t.pushInfo.locKey="lockey";
    templ.t.pushInfo.locArgs.size=2;
    templ.t.pushInfo.locArgs.item=locargs;

    templ.t.pushInfo.launchImage="launchimage";
    //IOS8.2以上版本支持
    templ.t.pushInfo.title="title";
    templ.t.pushInfo.titleLocKey="titlelockey";

    templ.t.pushInfo.titleLocArgs.size=2;
    templ.t.pushInfo.titleLocArgs.item=titlelocargs;

    //发送消息
    Result ret;
    char contentId[50] = "";
    ret = getAPNContentId(appKey, &templ, contentId, sizeof(contentId));
    if (ret == SUCCESS) {
        ListItem item;
        strcpy(item.item,dt);
        ListInfo target;
        target.size = 1;
        target.item = &item;

        cout << "============pushApnMessageToList============" << endl;
        IPushResult result = {0};
        result = pushAPNMessageToList(appKey, appId, &target, contentId);
        printResult(result);
    }
}

//apn单推
void toapnsingletest(){

    //准备数据
    Message msg = {0};
    msg.isOffline = 1;//是否离线下发
    msg.offlineExpireTime = 1000*3600*2;//离线下发有效期 毫秒
    SingleMessage singleMsg = {0};
        singleMsg.msg = msg;

    //IOS自定义消息
    Entry cmsg = {0};
    strcpy(cmsg.key,"cmsg");
    strcpy(cmsg.value,"cmsg");

    //title-loc-args赋值
    ListItem titlelocargs[2]={"titlelocargs1","titlelocargs2"};

    //locargs赋值
    ListItem locargs[2]={"locargs1","locargs2"};

    //APN模板，只包含了父类模板
    APNTemplate templ = {0};
    templ.t.appId = appId;
    templ.t.appKey = appKey;

    templ.t.pushInfo.badge=4;
    //templ.t.pushInfo.sound="test1.wav";
    //templ.t.pushInfo.contentAvailable=1;
    templ.t.pushInfo.category="";
    //templ.t.pushInfo.cmsg.size=1;
    //templ.t.pushInfo.cmsg.map = &cmsg;

    templ.t.pushInfo.body="body";
    templ.t.pushInfo.actionLocKey="";

    templ.t.pushInfo.locKey="";
    //templ.t.pushInfo.locArgs.size=2;
    //templ.t.pushInfo.locArgs.item=locargs;

    templ.t.pushInfo.launchImage="";
    //IOS8.2以上版本支持
    templ.t.pushInfo.title="";
    templ.t.pushInfo.titleLocKey="";

    //templ.t.pushInfo.titleLocArgs.size=2;
    //templ.t.pushInfo.titleLocArgs.item=titlelocargs;

    IPushResult result = {0};

    result = pushAPNMessageToSingle(appKey, &templ,appId, dt);
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

int main(){
    // 注意：接口传入字符必须为UTF-8编码，因ASCII字符UTF－8编码后与原先一样，所以可以不编码，但中文等非ASCII字符必须编码
    // 如果返回的类似错误"post http data failed, code=6"，错误码可百度CURL返回的错误码是什么意思，如http://www.cnblogs.com/wainiwann/p/3492939.html
    ////程序运行前只需初始化一遍，若已经初始化过即可不用，"编码"两个字为固定写法，不需要做转换
    Result r = pushInit(host, appKey, masterSecret, "编码");
    if(r!=SUCCESS){
        printf("pushInit for app failed: ret=%d\n", r);
        return -1;
    }
    //对单个用户的消息推送
    tosingletest();
    //为指定列表用户推荐
    //tolisttest();
    
    //为指定应用群推送消息
    //toapptest1();

    //APN单推
    toapnsingletest();
    //APN群推
  //  toapnlisttest();

    return 0;
}
