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
LATEST=$(bash scripts/query_all.sh | jq -r ".data.tokens | last")
TOKEN_ID=$(($LATEST+1))

OWNER="validator"
TOKEN_URI="https://drive.google.com/file/d/1QsSYv7X5neDiO-L4L0QTz5zP5u93ndQZ/view?usp=sharing"

# Extension data
image="CHANGE THIS"
image_data="CHANGE THIS"
external_url="CHANGE THIS"
description="A collection of Apes NFT"
name="Bored Apes in Juno"
attributes="CHANGE THIS"
background_color="CHANGE THIS"
animation_url="CHANGE THIS"
youtube_url="https://www.youtube.com/watch?v=tfSS1e3kYeo"

EXTENSION="{
    \"youtube_url\":\"$youtube_url\", 
    \"animation_url\":\"$animation_url\", 
    \"background_color\":\"$background_color\", 
    \"description\":\"$description\", 
    \"external_url\":\"$external_url\", 
    \"image\":\"$image\", 
    \"image_data\":\"$image_data\", 
    \"name\":\"$name\"
}"

MINT="{\"mint\": {\"token_id\": \"$TOKEN_ID\", \"owner\": \"$($BINARY keys show $OWNER -a)\", \"token_uri\": \"$TOKEN_URI\", \"extension\": $EXTENSION}}"

echo $MINT

RES=$($BINARY tx wasm execute "$CONTRACT_ADDRESS" "$MINT" --from "$OWNER" $TXFLAG --output json)
echo $RES

TXHASH=$(echo $RES | jq -r .txhash)

echo $TXHASH

# sleep for chain to update
sleep "$SLEEP_TIME"

RAW_LOG=$($BINARY query tx "$TXHASH" --chain-id "$CHAIN_ID" --node "$RPC" -o json | jq -r .raw_log)

echo $RAW_LOG

NAME_QUERY="{\"nft_info\": {\"token_id\": \"$TOKEN_ID\"}}"
OWNER_OF=$($BINARY query wasm contract-state smart "$CONTRACT_ADDRESS" "$NAME_QUERY" --node "$RPC" --output json)
echo $OWNER_OF