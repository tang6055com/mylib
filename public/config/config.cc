#include "config/config.h"
#include "errno.h"
#include "log/mig_log.h"
#include "basic/constants.h"
#include "basic/basictypes.h"
#include "logic/logic_comm.h"

namespace config {

static char config[] = "config";
static char database[] = "database";
static char cached[] = "cached";
static char queue[] = "queue";

static char mysql[] = "mysql";
static char mssql[] = "mssql";
static char redis[] = "redis";
static char memcached[] = "memcached";
static char kafka[] = "kafka";
static char hbase[] = "hbase";

static char host[] = "host";
static char port[] = "port";
static char user[] = "user";
static char pass[] = "pass";
static char source[] = "name";
static char additional[] = "additional";

static char id[] = "id";
static char desc[] = "desc";

/*
 static char sso[] = "sso";
 static char cert[] = "cert";
 static char path[] = "path";
 static char url[] = "url";
 static char serviceprovider[] = "serviceprovider";
 static char idprovider[] = "idprovider";
 static char cert_path[] = "cert_path";
 static char sp_url[] = "sp_url";
 static char idp_url[] = "idp_url";
 static char record[] = "record";
 static char mood_path[] = "mood_path";
 static char sytle_path[] = "sytle_path";
 static char remote[] = "remote";
 static char address[] = "address";
 */

static int32 config_flag = 0;
static int32 data_flag = 0;
static int32 cached_flag = 0;
static int32 queue_flag = 0;

FileConfig* FileConfig::config_ = NULL;

FileConfig::FileConfig() {

}

FileConfig::~FileConfig() {

}

FileConfig* FileConfig::GetFileConfig() {
  if (config_ == NULL) {
    config_ = new FileConfig();
  }
  return config_;
}

void FileConfig::CreateMysql(const char** atts) {
  mysql_db_list_.push_back(CreateDataBase(atts));
}

void FileConfig::CreateMSsql(const char** atts) {
  mssql_db_list_.push_back(CreateDataBase(atts));
}

void FileConfig::CreateRedis(const char** atts) {
  redis_list_.push_back(CreateCache(atts));
}

void FileConfig::CreateMemcached(const char** atts) {
  mem_list_.push_back(CreateCache(atts));
}

void FileConfig::CreateKafka(const char** atts) {
  kafka_list_.push_back(CreateQueue(atts));
}

base::ConnAddr FileConfig::CreateBaseInfo(const char** atts) {
  int i = 0;
  std::string sid;
  std::string shost;
  std::string sport;
  std::string suser;
  std::string spass;
  std::string sname;
  std::string sdesc;
  std::string sadd;
  for (i = 0; atts[i] != 0; i += 2) {
    if (strcmp(atts[i], host) == 0)
      shost.assign(atts[i + 1]);
    else if (strcmp(atts[i], port) == 0)
      sport.assign(atts[i + 1]);
    else if (strcmp(atts[i], pass) == 0)
      spass.assign(atts[i + 1]);
    else if (strcmp(atts[i], user) == 0)
      suser.assign(atts[i + 1]);
    else if (strcmp(atts[i], source) == 0)
      sname.assign(atts[i + 1]);
    else if (strcmp(atts[i], id) == 0)
      sid.assign(atts[i + 1]);
    else if (strcmp(atts[i], desc) == 0)
      sdesc.assign(atts[i + 1]);
    else if (strcmp(atts[i], additional) == 0)
        sadd.assign(atts[i + 1]);

  }

  if (sid.empty())
    sid = "1";

  base::ConnAddr addr(atoi(sid.c_str()), shost.c_str(), atoi(sport.c_str()), suser.c_str(),
                      spass.c_str(), sname.c_str(), sdesc.c_str(), sadd.c_str());

  return addr;
}

base::ConnAddr FileConfig::CreateQueue(const char** atts) {

  return CreateBaseInfo(atts);
}

base::ConnAddr FileConfig::CreateCache(const char** atts) {
  return CreateBaseInfo(atts);
}

base::ConnAddr FileConfig::CreateDataBase(const char** atts) {
  return CreateBaseInfo(atts);
}

void FileConfig::OnDataBase(const char* name, const char** atts) {
  if (strcmp(name, mysql) == 0)
    CreateMysql(atts);
  else if (strcmp(name, mssql) == 0)
    CreateMSsql(atts);
}

void FileConfig::OnCache(const char* name, const char** atts) {
  if (strcmp(name, redis) == 0)
    CreateRedis(atts);
  else if (strcmp(name, memcached) == 0)
    CreateMemcached(atts);
}
void FileConfig::OnQueue(const char* name, const char** atts) {
  if (strcmp(name, kafka) == 0)
    CreateKafka(atts);
}

#define XMLCALL

static void XMLCALL OnConfigStart(void* usrData, const char* name,
                                  const char** atts) {
  FileConfig* file_config = (FileConfig*) usrData;
  int i = 0;
  std::string shost;
  std::string sport;
  std::string suser;
  std::string spass;
  std::string sname;
  if (config_flag && (strcmp(name, database) == 0))
    data_flag = 1;
  else if (config_flag && (strcmp(name, cached) == 0))
    cached_flag = 1;
  else if (config_flag && (strcmp(name, queue)) == 0) {
    queue_flag = 1;
  } else if ((strcmp(name, config)) == 0) {
    config_flag = 1;
  }

  if (data_flag) {
    file_config->OnDataBase(name, atts);
  } else if (config_flag && cached_flag) {
    file_config->OnCache(name, atts);

  } else if (config_flag && queue_flag) {
    file_config->OnQueue(name, atts);
  }
}

static void XMLCALL OnConfigEnd(void* usrData, const char* name) {
  //MIG_INFO(USER_LEVEL, "[OnConfigEnd,name=%s,config_flag:%d]", name, config_flag);
  if (strcmp(name, config) == 0)
    config_flag = 0;
  else if (strcmp(name, database) == 0)
    data_flag = 0;
  else if (strcmp(name, cached) == 0)
    cached_flag = 0;
  else if (strcmp(name, queue) == 0)
    queue_flag = 0;
}

bool FileConfig::LoadConfig(std::string& path) {
  char* xml = NULL;
  size_t len = 0;
  size_t amt = 0;
  FILE* fp = fopen(path.c_str(), "r");
  if (fp == NULL)
    return false;
  fseek(fp, 0, SEEK_END);
  len = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  if (len <= 0) {
    MIG_ERROR(USER_LEVEL, "%s error\n", path.c_str());
    fclose(fp);
    return false;
  }
  xml = new char[len + 1];
  if (xml == NULL) {
    MIG_ERROR(USER_LEVEL, "alloc error %d", errno);
    fclose(fp);
    return false;
  }

  do {
    amt = fread(xml + amt, 1, len, fp);
    len -= amt;
  } while (len != 0);

  XML_Parser parser = XML_ParserCreate(NULL);
  XML_SetUserData(parser, this);
  XML_SetElementHandler(parser, OnConfigStart, OnConfigEnd);

  if (XML_Parse(parser, xml, amt, 1) == XML_STATUS_ERROR) {
    MIG_ERROR(USER_LEVEL, "XML Parser error:%s at line %llu",
              XML_ErrorString(XML_GetErrorCode(parser)),
              XML_GetCurrentLineNumber(parser));
    XML_ParserFree(parser);
    if (xml) {
      delete[] xml;
      xml = NULL;
    }
    return false;
  }

  XML_ParserFree(parser);
  if (xml) {
    delete xml;
    xml = NULL;
  }
  return true;
}

}
