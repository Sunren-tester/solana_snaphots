#!/bin/bash
# set -x # uncomment to enable debug
echo "###################### WARNING!!! ###################################"
echo "###   This script will perform the following operations:          ###"
echo "###   * delete ledger and snapshots                               ###"
echo "###   * download snapshot                                         ###"
echo "###   * wait for catchup                                          ###"
echo "###                                                               ###"
echo "###   *** Script provided by MARGUS.ONE                           ###"
echo "#####################################################################"

catchup_info() {
  while true; do
    rpcPort=$(ps aux | grep solana-validator | grep -Po "\-\-rpc\-port\s+\K[0-9]+")
    sudo -i -u sunren solana catchup --our-localhost $rpcPort
    status=$?
    if [ $status -eq 0 ];then
      exit 0
    fi
    echo "waiting next 30 seconds for rpc"
    sleep 30
  done
}

service_file=/home/sunren/solana/solana.service
LEDGER=$(cat $service_file | grep "\--ledger" | awk '{ print $2 }' )
SNAPSHOTS=$(cat $service_file | grep "\--snapshots" | awk '{ print $2 }' )
IP=$(wget -q -4 -O- http://icanhazip.com)

if [ "$LEDGER" == "" ]; then 
service_file=/home/sunren/solana/validator.sh
LEDGER=$(cat $service_file | grep "\--ledger" | awk '{ print $2 }' )
SNAPSHOTS=$(cat $service_file | grep "\--snapshots" | awk '{ print $2 }' )
fi

if [ "$LEDGER" == "" ]; then LEDGER=/home/sunren/solana/ledger
fi

if [ -f $service_file ]; then
sudo systemctl stop solana

if [ "$SNAPSHOTS" == "" ]; then 
    SNAPSHOTS=$LEDGER
    rm -fr $SNAPSHOTS/*
else
    rm -fr $LEDGER/*
    rm -fr $SNAPSHOTS/*
fi

if ! [ -d $SNAPSHOTS ]; then
mkdir $SNAPSHOTS
fi

cd $SNAPSHOTS

if [ ${IP:0:10} == "91.211.83." ];then
if [ ${IP} == "91.211.83.222" ];then
wget --trust-server-names http://91.211.83.220/snapshot.tar.bz2 && wget --trust-server-names http://91.211.83.220/incremental-snapshot.tar.bz2
else
#wget --trust-server-names http://solana.margus.one/snapshot.tar.bz2 && wget --trust-server-names http://solana.margus.one/incremental-snapshot.tar.bz2
wget --trust-server-names http://91.211.83.222/snapshot.tar.bz2 && wget --trust-server-names http://91.211.83.222/incremental-snapshot.tar.bz2
fi
elif [ ${IP:0:10} == "185.81.65." ];then
wget --trust-server-names http://185.81.65.75/snapshot.tar.bz2 && wget --trust-server-names http://185.81.65.75/incremental-snapshot.tar.bz2
elif [ ${IP} == "5.189.79.58" ];then
#wget --trust-server-names http://92.248.252.110/snapshot.tar.bz2 && wget --trust-server-names http://92.248.252.110/incremental-snapshot.tar.bz2
wget --trust-server-names http://185.81.65.75/snapshot.tar.bz2 && wget --trust-server-names http://185.81.65.75/incremental-snapshot.tar.bz2
#wget --trust-server-names http://91.211.83.222/snapshot.tar.bz2 && wget --trust-server-names http://91.211.83.222/incremental-snapshot.tar.bz2
elif [ ${IP} == "92.248.252.110" ];then
#wget --trust-server-names https://shdw-drive.genesysgo.net/snapshots/latest && wget --trust-server-names https://shdw-drive.genesysgo.net/snapshots/latest-incremental
#wget --trust-server-names http://solana.margus.one/snapshot.tar.bz2 && wget --trust-server-names http://solana.margus.one/incremental-snapshot.tar.bz2
#wget --trust-server-names http://146.59.55.49:8899/snapshot.tar.bz2 && wget --trust-server-names http://146.59.55.49:8899/incremental-snapshot.tar.bz2
#wget --trust-server-names http://5.189.79.58/snapshot.tar.bz2 && wget --trust-server-names http://5.189.79.58/incremental-snapshot.tar.bz2
wget --trust-server-names http://185.81.65.75/snapshot.tar.bz2 && wget --trust-server-names http://185.81.65.75/incremental-snapshot.tar.bz2
elif [ ${IP} == "176.99.142.187" ];then
wget --trust-server-names http://185.81.65.75/snapshot.tar.bz2 && wget --trust-server-names http://185.81.65.75/incremental-snapshot.tar.bz2
#wget --trust-server-names http://solana.margus.one/snapshot.tar.bz2 && wget --trust-server-names http://solana.margus.one/incremental-snapshot.tar.bz2
elif [ ${IP:0:10} == "195.18.27." ];then
wget --trust-server-names http://91.211.83.222/snapshot.tar.bz2 && wget --trust-server-names http://91.211.83.222/incremental-snapshot.tar.bz2
#wget --trust-server-names https://api.mainnet-beta.mmg.ink/snapshot.tar.bz2 && wget --trust-server-names https://api.mainnet-beta.mmg.ink/incremental-snapshot.tar.bz2
else
curl -fsSL https://raw.githubusercontent.com/Sunren-tester/solana_snaphots/main/finder.sh | bash
exit 0
fi

sudo systemctl start solana
catchup_info

else
echo "solana.service not found! Default: /home/sunren/solana/solana.service"
fi
