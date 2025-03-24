# bitbucket

[README](README.md) | [中文文档](README_zh.md)

+ LTR Version: v8.9.19 - MYSQL and PostgreSQL
+ LTR Version: v8.19.9


Thanks to: [voarsh2](https://github.com/voarsh2) for [Bitbucket test data](https://github.com/haxqer/jira/issues/30) 

v8.x+ requires an [updated agent](https://github.com/haxqer/bitbucket/issues/1)

default port: 7990

## requirement
- docker: 17.09.0+
- docker-compose: 1.24.0+

## How to run with docker-compose

- start bitbucket & mysql

```
    git clone https://github.com/haxqer/bitbucket.git \
        && cd bitbucket \
        && docker-compose pull \
        && docker-compose up
```

- start bitbucket & mysql daemon

```
    docker-compose up -d
```

- default db(mysql8.0) configure:

```bash
    driver=mysql8.0
    host=mysql-bitbucket
    port=3306
    db=bitbucket
    user=root
    passwd=123456
```

## How to run with docker

- start bitbucket

```
    docker volume create bitbucket_home_data && docker network create bitbucket-network && docker run -p 7990:7990 -p 7999:7999 -v bitbucket_home_data:/var/bitbucket --network bitbucket-network --name bitbucket-srv -e TZ='Asia/Shanghai' haxqer/bitbucket:8.9.6
```

- config your own db:


## Bitbucket 8.x does not allow new MYSQL installations. Use DB migratior to migrate to PostgreSQL


## How to hack bitbucket

```
docker exec bitbucket-srv java -jar /var/agent/atlassian-agent.jar \
    -p bitbucket \
    -m Hello@world.com \
    -n Hello@world.com \
    -o your-org \
    -d \
    -s you-server-id-xxxx
```

## How to hack bitbucket plugin

- .eg I want to use BigGantt plugin
1. Install BigGantt from jira marketplace.
2. Find `App Key` of BigGantt is : `eu.softwareplant.biggantt`
3. Execute :

```
docker exec bitbucket-srv java -jar /var/agent/atlassian-agent.jar \
    -p eu.softwareplant.biggantt \
    -m Hello@world.com \
    -n Hello@world.com \
    -o your-org \
    -d \
    -s you-server-id-xxxx
```

