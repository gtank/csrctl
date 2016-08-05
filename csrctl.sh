#!/bin/sh

API="127.0.0.1:8080/apis/certificates/v1alpha1/certificatesigningrequests"
CSR_ARG="$2"

# Set the status of a CSR to 'approved'
approveCSR() {
  local object=`curl -sN "${API}/${CSR_ARG}"`
  local approved=`echo "${object}" | jq -cr ".status.conditions = [{"type":\"Approved\"}]"`
  echo -ne "${approved}" | curl -X PUT -H "Content-Type: application/json" --data @- "${API}/${CSR_ARG}/approval"
}

# Set the status of a CSR to denied
denyCSR() {
  local object=`curl -sN "${API}/${CSR_ARG}"`
  local approved=`echo "${object}" | jq -cr ".status.conditions = [{"type":\"Denied\"}]"`

  echo -ne "${approved}" | curl -X PUT -H "Content-Type: application/json" --data @- "${API}/${CSR_ARG}/approval"
}

createCSR() {
  curl -H "Content-Type: application/json" --data @${CSR_ARG} "${API}"
}

dumpCert() {
  curl "${API}/${CSR_ARG}" | jq -rc .status.certificate | base64 -d | openssl x509 -noout -text
}

getCSR() {
  curl "${API}/${CSR_ARG}"
}

watchCSR() {
  curl "${API}?watch=true"
}

case "$1" in
  create) createCSR;;
  approve) approveCSR;;
  deny) denyCSR;;
  get) getCSR;;
  dump) dumpCert;;
  watch) watchCSR;;
  *) echo "usage: csrctl.sh [create|approve|deny|get|dump|watch] <csr-name|csr-file>";;
esac
