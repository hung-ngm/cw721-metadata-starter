#!/bin/bash

DEFAULT_DEV_ADDRESS="juno16g2rahf5846rxzp3fwlswy08fz8ccuwk03k57y"

echo "Provisioning - juno address $DEFAULT_DEV_ADDRESS"

# pinched and adapted from whoami/DA0DA0
IMAGE_TAG=${2:-"v2.3.0-beta"}
CONTAINER_NAME="juno_cw_starter"
BINARY="docker exec -i $CONTAINER_NAME junod"
DENOM='ujunox'
CHAIN_ID='testing'
RPC='http://localhost:26657/'
TXFLAG="--gas-prices 0.1$DENOM --gas auto --gas-adjustment 1.3 -y -b block --chain-id $CHAIN_ID --node $RPC"
BLOCK_GAS_LIMIT=${GAS_LIMIT:-100000000} # should mirror mainnet

CONTRACT_ADDRESS="juno14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9skjuwg8"

# Change Token Id here
TOKEN_ID="1"

QUERY="{\"nft_info\": {\"token_id\": \"$TOKEN_ID\"}}"
echo $($BINARY query wasm contract-state smart "$CONTRACT_ADDRESS" "$QUERY" --node "$RPC" --output json | jq --color-output -r .)