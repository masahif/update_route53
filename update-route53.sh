#!/bin/sh
set -e -o pipefail

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id/)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e s/.$//)
HOST_NAME=$(aws --region ${REGION} ec2 describe-instances --instance-ids ${INSTANCE_ID} --query "Reservations[0].Instances[0].Tags[?Key=='Name'].Value" --output text)
HOST_ZONE_NAME=$(aws --region ${REGION} ec2 describe-instances --instance-ids ${INSTANCE_ID} --query "Reservations[0].Instances[0].Tags[?Key=='HostZoneName'].Value" --output text)
FQDN="${HOST_NAME}.${HOST_ZONE_NAME}"
IP_ADDR=$(curl -s http://checkip.amazonaws.com/)

HOST_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name ${HOST_ZONE_NAME} --query "HostedZones[?Name==\`${HOST_ZONE_NAME}\`].Id" --output text)

if [ -z "$IP_ADDR" ]; then
  echo "Failed to retrieve IP address"
  exit 1
fi

if [ -z "$FQDN" ]; then
  echo "Failed to retrieve FQDN"
  exit 1
fi

TMP_FILE=$(mktemp)
cat > "${TMP_FILE}" << EOF
{
  "Comment":"Updated A record by shell script",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "ResourceRecords": [
          {"Value": "${IP_ADDR}"}
        ],
        "Name": "${FQDN}",
        "Type": "A",
        "TTL": 300
      }
    }
  ]
}
EOF

echo "-- REQUEST --"
cat ${TMP_FILE}

echo "-- RESPONSE --"
aws route53 change-resource-record-sets \
  --region ${REGION} \
  --hosted-zone-id "/hostedzone/${HOST_ZONE_ID}" \
  --change-batch "file://${TMP_FILE}"

rm "${TMP_FILE}"
