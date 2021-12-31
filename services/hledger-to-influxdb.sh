set -euo pipefail

TMPDIR='/tmp/hledger-to-influx'

function cleanup() {
    rm -rf "$TMPDIR"
}

trap cleanup EXIT

mkdir $TMPDIR
cd $TMPDIR
influx -execute 'drop database finance'
influx -execute 'create database finance'
git clone gitea@git.balajisivaraman.com:balajisivaraman/personal-finance.git
export LEDGER_FILE="${TMPDIR}/personal-finance/current.journal"
git clone gitea@git.balajisivaraman.com:balajisivaraman/hledger-scripts.git
cd hledger-scripts
nix run
