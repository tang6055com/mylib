#ifndef _MYLIB_PUBLIC_CONFIG_CONFIG_H__
#define _MYLIB_PUBLIC_CONFIG_CONFIG_H__

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <expat.h>
#include <list>
#include "config_info.h"

namespace config{
	
class FileConfig{
public:
    FileConfig();
    virtual ~FileConfig();
    bool LoadConfig(std::string& path);
public:
    static FileConfig* GetFileConfig();
public:
    void OnDataBase(const char* name, const char** atts);
    void OnCache(const char* name, const char** atts);
    void OnQueue(const char* name, const char** atts);
public:
    void CreateMysql(const char** atts);
    void CreateMSsql(const char** atts);
    void CreateMemcached(const char** atts);
    void CreateRedis(const char** atts);
    void CreateHBase(const char** atts);
    void CreateKafka(const char** atts);
private:
    base::ConnAddr CreateDataBase(const char** atts);
    base::ConnAddr CreateCache(const char** atts);
    base::ConnAddr CreateQueue(const char** atts);
    base::ConnAddr CreateBaseInfo(const char** atts);
private:
    static FileConfig*  config_;
public:
    std::list<base::ConnAddr>  mysql_db_list_;
    std::list<base::ConnAddr>  mem_list_;
    std::list<base::ConnAddr>  redis_list_;
    std::list<base::ConnAddr>  mssql_db_list_;
    std::list<base::ConnAddr>  hbase_list_;
    std::list<base::ConnAddr>  kafka_list_;
/*
public:
    std::string      certificate_path_; 
    std::string      idp_url_;
    std::string      sp_url_; 
	std::string      mood_path_;
	std::string      style_path_;
	std::string      usr_local_music_path_;
	std::string      host_;
	std::string      port_;
*/

};

}
#endif
