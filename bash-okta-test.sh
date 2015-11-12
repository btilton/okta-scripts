#!/usr/bin/env bash
#############################
#      Author : Brian Tilton
#        Date : 8/18/2015
#       Title : bash-okta-test.sh
# Description : Script to experiment with and test the Okta API
#############################

apifile="`dirname $0`/api.token"
APITOKEN=$(<$apifile)

username=$1

curl -H "Authorization: SSWS $APITOKEN" \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Cache-Control: no-cache" \
-X GET https://elance-odesk.oktapreview.com/api/v1/users/$username

printf "\n"
