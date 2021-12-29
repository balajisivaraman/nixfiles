set -euo pipefail

TMPDIR='/tmp/fetch-prices'

function cleanup() {
    rm -rf "$TMPDIR"
}

trap cleanup EXIT

mkdir $TMPDIR
cd $TMPDIR
git clone gitea@git.balajisivaraman.com:balajisivaraman/hledger-scripts.git
git clone gitea@git.balajisivaraman.com:balajisivaraman/personal-finance.git
./hledger-scripts/market-prices/market-prices.py < ./hledger-scripts/market-prices/commodities.json >> personal-finance/prices
cd personal-finance
git add prices
date=$(date +%F)
git commit -m "feat: update commodity prices on ${date}"
git push origin main
