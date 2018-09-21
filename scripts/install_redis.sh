#!/usr/bin/env bash
set -x

source /usr/local/bootstrap/var.env

echo 'Start Setup of Vault Environment'
IFACE=`route -n | awk '$1 == "192.168.2.0" {print $8}'`
CIDR=`ip addr show ${IFACE} | awk '$2 ~ "192.168.2" {print $2}'`
IP=${CIDR%%/24}

if [ "${TRAVIS}" == "true" ]; then
  IP="127.0.0.1"
fi

if [ "${TRAVIS}" == "true" ]; then
  LEADER_IP="127.0.0.1"
fi

register_redis_service_with_consul () {
    
    echo 'Start to register service with Consul Service Discovery'

    # configure Audit Backend
    tee redis_service.json <<EOF
    {
      "ID": "redis",
      "Name": "redis",
      "Tags": [
        "primary",
        "v1"
      ],
      "Address": "${IP}",
      "Port": 6379,
      "Meta": {
        "redis_version": "4.0"
      },
      "EnableTagOverride": false,
      "Checks": [
          {
            "args": ["/usr/local/bootstrap/scripts/consul_redis_ping.sh"],
            "interval": "10s"
          },
          {
              "args": ["/usr/local/bootstrap/scripts/consul_redis_verify.sh"],
              "interval": "10s"
          }
        ]
    }
EOF
  
  curl \
      -v \
      --request PUT \
      --data @redis_service.json \
      http://127.0.0.1:8500/v1/agent/service/register

  # curl \
  #   -v \
  #   --request PUT \
  #   --data @redis_service.json \
  #   http://${LEADER_IP}:8500/v1/catalog/register

   curl \
      -v \
      http://127.0.0.1:8500/v1/agent/services

     curl \
      -v \
      http://${LEADER_IP}:8500/v1/catalog/services
   
    echo 'Register service with Consul Service Discovery Complete'
}

#install this package in base image in the future
which jq &>/dev/null || {
 sudo apt-get update
 sudo apt-get install -y jq
}

sudo echo "${REDIS_MASTER_IP}     ${REDIS_MASTER_NAME}" >> /etc/hosts

sudo VAULT_TOKEN=`cat /usr/local/bootstrap/.database-token` VAULT_ADDR="http://${LEADER_IP}:8200" consul-template -template "/usr/local/bootstrap/conf/master.redis.ctpl:/etc/redis/redis.conf" -once
sudo chown redis:redis /etc/redis/redis.conf
sudo chmod 640 /etc/redis/redis.conf

# restart redis, register the service with consul and restart consul agent
sudo service redis-server restart
register_redis_service_with_consul
sudo killall -1 consul


