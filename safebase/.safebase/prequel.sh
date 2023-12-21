#! /usr/bin/env bash

trigger_transaction_and_poll() {
  if [ -z "$PREQUEL_API_KEY" ]; then
    echo "Prequel API Key not set."
    exit 1
  fi

  readonly destination_id="${1:-$DESTINATION_ID}"

  if [ -z "$destination_id" ]; then
    echo "Destination ID not set."
    exit 1
  fi

  curl_out=$(curl --request POST \
    --url https://api.prequel.co/destinations/"$destination_id"/transfer \
    --header 'Content-Type: application/json' \
    --header "X-API-KEY: $PREQUEL_API_KEY" \
    --data '
      {
           "full_refresh": true
      }
    ')

  echo ""
  echo "$curl_out" | jq
  echo ""

  transfer_id=$(echo "$curl_out" | jq '.data.transfer_id')

  echo "polling for transfer: $transfer_id"
  echo 'use ctrl+c to stop polling'
  while :; do
    echo "Requesting..."
    curl --request GET \
      --url https://api.prequel.co/transfers/"$transfer_id" \
      --header 'Accept: application/json' \
      --header "X-API-KEY: $PREQUEL_API_KEY" | jq
    sleep 5
  done
}

validate_prequel_config() {
  curl --request POST \
    --url https://api.prequel.co/actions/validate-config \
    --header 'Content-Type: application/json' \
    --header "X-API-KEY: $PREQUEL_API_KEY" \
    --data "$(cat "$1")"
}
