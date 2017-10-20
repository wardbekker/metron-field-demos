#!/bin/sh

# setup metron bits
echo "Setting up Parser"
curl -X POST -u admin:admin -d@parser.json -H 'Content-Type: application/json' $REST_URL/api/v1/sensor/parser/config 
echo "\nSetting up Enrichment"
curl -X POST -u admin:admin -d@enrichment.json -H 'Content-Type: application/json' $REST_URL/api/v1/sensor/enrichment/config/geohash
echo "\nSetting up Indexing"
curl -X POST -u admin:admin -d@indexing.json -H 'Content-Type: application/json' $REST_URL/api/v1/sensor/indexing/config/geohash
echo "\nConfigure ES template"
curl -X POST -d@es.json -H 'Content-Type: application/json' $ES_URL/_template/geohash
echo "Setup kafka"
curl -X POST -u admin:admin -d@kafka.json -H 'Content-Type: application/json' $REST_URL/api/v1/kafka/topic

echo "\nUpload sample data"
ssh ${METRON_HOST} mkdir geohash
rsync -zre ssh remote/ ${METRON_HOST}:geohash/

# do a run for Fun
echo "\nStarting parser"
curl -u admin:admin ${REST_URL}/api/v1/storm/parser/start/geohash 
ssh ${METRON_HOST} '~/geohash/load_data.sh'