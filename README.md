# `cts-apigee` README

CTS Apigee demo environment

## Create environment

```bash
AUTH="Authorization: Bearer $(gcloud auth print-access-token)"
PROJECT_ID="cts-apigee-eval"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
RUNTIME_LOCATION="europe-west1"
SERVICE_ATT=$(curl -X GET -H "$AUTH"  \
  "https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/instances" \
  | jq -r '.instances[0].serviceAttachment')
gcloud compute network-endpoint-groups create demo-neg \
  --network-endpoint-type=private-service-connect \
  --psc-target-service=$SERVICE_ATT --region=$RUNTIME_LOCATION   --project=$PROJECT_ID
gcloud compute addresses create apigee-demo   --ip-version=IPV4 --global --project=$PROJECT_ID
EXTERNAL_IP=$(gcloud compute addresses describe --global apigee-demo \
  --project=$PROJECT_ID --format="value(address)")
gcloud compute backend-services create apigee-backend \
 --load-balancing-scheme=EXTERNAL_MANAGED   --protocol=HTTPS   --global --project=$PROJECT_ID
gcloud compute backend-services add-backend apigee-backend \
  --network-endpoint-group=demo-neg \
  --network-endpoint-group-region=$RUNTIME_LOCATION \
  --global --project=$PROJECT_ID
gcloud compute url-maps create apigee-url-map --default-service=apigee-backend \
  --global --project=$PROJECT_ID
gcloud compute ssl-certificates create apigee-cert \
  --domains $EXTERNAL_IP.nip.io --project=$PROJECT_ID
gcloud compute ssl-certificates list
curl -H "$AUTH"   -X PATCH   -H "Content-Type:application/json"  \
 -d '{"hostnames":["'"$EXTERNAL_IP.nip.io"'"]}' \
  "https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/envgroups/eval-group"
gcloud compute target-https-proxies create apigee-target-proxy  \
 --url-map=apigee-url-map   --ssl-certificates=apigee-cert --project=$PROJECT_ID
gcloud compute forwarding-rules create apigee-forwarding-rule  \
 --load-balancing-scheme=EXTERNAL_MANAGED  --network-tier=PREMIUM  \
 --address=apigee-demo   --target-https-proxy=apigee-target-proxy   --ports=443 \
   --global --project=$PROJECT_ID
```

## Prep machine

```bash
export AUTH="Authorization: Bearer $(gcloud auth print-access-token)"
export PROJECT_ID=cts-apigee-eval
export INTERNAL_LOAD_BALANCER_IP=$(curl -H "$AUTH" \
  https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/instances -s \
  | jq -r '.instances[0].host')
export HOST=$EXTERNAL_IP.nip.io
export DEVELOPER=developer@example.com
export APIKEY=wotvFQDu2Xlc6k9k5AHiKLTI3GTsbd5jQm8eCWaGAAgXWdBz
```

## Enable monetization

```bash
curl "https://apigee.googleapis.com/v1/organizations/$PROJECT_ID" \
  -X GET \
  -H "$AUTH"
curl "https://apigee.googleapis.com/v1/organizations/$PROJECT_ID:setAddons" \
  -X POST \
  -H "$AUTH" \
  -H "Content-type: application/json" \
  -d '{
    "addonsConfig": {
      "monetizationConfig": {
          "enabled": "true"
      }
    }
  }'
```

## Setup account type

```bash
curl -H "$AUTH" \
-H "Content-type: application/json" \
-X PUT \
-d '{
"billingType": "PREPAID",
}' \
https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/developers/$DEVELOPER/monetizationConfig
curl  -H "$AUTH" --json '{"apiproduct":"demo"}' \
  "https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/developers/$DEVELOPER/\
  subscriptions"
```

## Check API balance

```bash
curl -H "$AUTH" https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/developers/$DEVELOPER/balance
```

## Credit

```bash
curl -H "$AUTH" \
-H "Content-type: application/json" \
-X POST \
-d '{
  "transactionAmount": {
     "currencyCode": "GBP",
     "units": "150",
     "nanos": 210000000
  },
  "transactionId": "ab31b63e-f8e8-11eb-9a03-0242ac130003"
}' \
https://apigee.googleapis.com/v1/organizations/$PROJECT_ID/developers/$DEVELOPER/balance:credit
```

## Single call

```bash
curl -i -H "Host: $HOST"  \
  https://$HOST/v1/demo/get?apikey=$APIKEY
```

## Call in loop

```bash
for i in `seq 1 10`; do
  curl -i -H "Host: $HOST"  \
    "https://$HOST/v1/demo/get?apikey=$APIKEY&requestno=req_$i";
  sleep 2;
done
```

## Call limited API

```bash
curl -i -H "Host: $HOST"  \
  https://$HOST/v1/demo/limited?apikey=$APIKEY
```

## Call Limited API in loop, triggers spike arrest

```bash
for i in `seq 1 15`; do
  curl -i -H "Host: $HOST"  \
    "https://$HOST/v1/demo/limited?apikey=$APIKEY&requestno=req_$i";
done
```
