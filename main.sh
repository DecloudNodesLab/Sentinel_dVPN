#!/bin/bash
CONFIG_PATH="/root/.sentinelnode/config.toml"
V2RAY_CONFIG_PATH="/root/.sentinelnode/v2ray.toml"

# Function to check if a variable is set and print an error message if it's not.
check_var() {
    local var_name="$1"
    local error_message="$2"
    local example="$3"
    if [[ -z ${!var_name} ]]; then
        echo "$error_message"
        echo "For example: $example"
        sleep infinity
    fi
}
check_var "LISTEN_PORT" "CHECK YOUR LISTEN_PORT AND REMOTE_PORT IN DEPLOY.YML !" "LISTEN_PORT=3333 REMOTE_PORT=8585"
check_var "IPV4_ADDRESS" "CHECK YOUR IPV4 ADDRESS IN DEPLOY.YML !" "IPV4_ADDRESS=XXX.XXX.XXX.XXX"

# Initialize configurations.
sentinelnode config init && sentinelnode v2ray config init

# Generate TLS certificates.
(echo ;echo ;echo ;echo ;echo ;echo ;echo )| openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -x509 -sha256 -days 365 -nodes -out ${HOME}/tls.crt -keyout ${HOME}/tls.key

if [[ -n $GAS_ADJUSTMENT ]] ; then sed -i.bak -e "s|^gas_adjustment *=.*|gas_adjustment = $GAS_ADJUSTMENT|;" $CONFIG_PATH ; fi
if [[ -n $GAS ]] ; then sed -i.bak -e "s|^gas *=.*|gas = $GAS|;" $CONFIG_PATH ; fi
if [[ -n $GAS_PRICES ]] ; then sed -i.bak -e "s|^gas_prices *=.*|gas_prices = \"$GAS_PRICES\"|;" $CONFIG_PATH ; fi
if [[ -n $CHAIN ]] ; then sed -i.bak -e "s|^id *=.*|id = \"$CHAIN\"|;" /root/.sentinelnode/config.toml ; fi
if [[ -n $RPC_ADDRESS ]] ; then sed -i.bak -e "s|^rpc_address *=.*|rpc_address = \"$RPC_ADDRESS\"|;" $CONFIG_PATH ; fi
if [[ -n $SIMULATE_AND_EXECUTE ]] ; then sed -i.bak -e "s|^simulate_and_execute *=.*|simulate_and_execute = $SIMULATE_AND_EXECUTE|;" $CONFIG_PATH ; fi
if [[ -z $HANDSHAKE ]] ; then HANDSHAKE=false && sed -i.bak -e "s|^enable *=.*|enable = \"$HANDSHAKE\"|;" $CONFIG_PATH ; fi
if [[ -n $PEERS ]] ; then sed -i.bak -e "s|^peers *=.*|peers = $PEERS|;" /root/.sentinelnode/config.toml ; fi
if [[ -n $BACKEND ]] ; then sed -i.bak -e "s/^backend *=.*/backend = \"$BACKEND\"/;" $CONFIG_PATH ; else sed -i.bak -e "s/^backend *=.*/backend = \"test\"/;" $CONFIG_PATH ; fi
if [[ -n $WALLET_NAME ]] ; then sed -i.bak -e "s/^from *=.*/from = \"$WALLET_NAME\"/;" $CONFIG_PATH; else sed -i.bak -e "s/^from *=.*/from = \"wallet\"/;" $CONFIG_PATH ; fi
if [[ -n $INTERVAL_SET_SESSIONS ]] ; then sed -i.bak -e "s|^interval_set_sessions *=.*|interval_set_sessions = \"$INTERVAL_SET_SESSIONS\"|;" $CONFIG_PATH ;fi
if [[ -n $INTERVAL_UPDATE_SESSIONS ]] ; then sed -i.bak -e "s|^interval_update_sessions *=.*|interval_update_sessions = \"$INTERVAL_UPDATE_SESSIONS\"|;" $CONFIG_PATH ; fi
if [[ -n $INTERVAL_UPDATE_STATUS ]] ; then sed -i.bak -e "s|^interval_update_status *=.*|interval_update_status = \"$INTERVAL_UPDATE_STATUS\"|;" $CONFIG_PATH ; fi
if [[ -n $REMOTE_PORT ]] ; then sed -i.bak -e "s|^listen_on *=.*|listen_on = \"0.0.0.0:$REMOTE_PORT\"|;" $CONFIG_PATH ; fi
if [[ -n $MONIKER ]] ; then sed -i.bak -e "s/^moniker *=.*/moniker = \"$MONIKER\"/;" $CONFIG_PATH ; fi
if [[ -n $IPV4_ADDRESS ]] ; then sed -i.bak -e "s|^ipv4_address *=.*|ipv4_address = \"$IPV4_ADDRESS\"|;" $CONFIG_PATH ; fi
REMOTE_URL="$IPV4_ADDRESS:$REMOTE_PORT" 
sed -i.bak -e "s|^remote_url *=.*|remote_url = \"https://$REMOTE_URL\"|;" $CONFIG_PATH
if [[ -n $TYPE ]] ; then sed -i.bak -e "s|^type *=.*|type = \"$TYPE\"|;" $CONFIG_PATH ; else sed -i.bak -e "s/^type *=.*/type = \"v2ray\"/;" $CONFIG_PATH ; fi
if [[ -n $GIGABYTE_PRICES ]] ; then sed -i.bak -e "s|^gigabyte_prices *=.*|gigabyte_prices = \"$GIGABYTE_PRICES\"|;" $CONFIG_PATH ; fi
if [[ -n $HOURLY_PRICES ]] ; then sed -i.bak -e "s|^hourly_prices *=.*|hourly_prices = \"$HOURLY_PRICES\"|;" $CONFIG_PATH ; fi

if [[ -n $LISTEN_PORT ]] ; then sed -i.bak -e "s|^listen_port *=.*|listen_port = \"$LISTEN_PORT\"|;" $V2RAY_CONFIG_PATH ; fi
if [[ -n $TRANSPORT ]] ; then sed -i.bak -e "s|^transport *=.*|transport = \"$TRANSPORT\"|;" $V2RAY_CONFIG_PATH ; fi

(echo `echo $MNEMONIC_BASE64 | base64 -d`)|sentinelnode keys add --recover
mv ${HOME}/tls.crt ${HOME}/.sentinelnode/tls.crt && mv ${HOME}/tls.key ${HOME}/.sentinelnode/tls.key
PATH=$PATH:/root/v2ray
sentinelnode start
