#!/bin/bash
# Bytecode verification for FunDistributor
# Contract: 0x125b606c67e8066da65069652b656c19717745fa
# Compiler: soljson v0.1.1+commit.6ff4cd6 (optimizer disabled)
#
# Usage: ./verify.sh
#
# Prerequisites:
#   - Node.js
#   - curl (to fetch compiler binary)
#   - Etherscan API key (optional, for on-chain bytecode fetch)

set -euo pipefail

CONTRACT="0x125b606c67e8066da65069652b656c19717745fa"
COMPILER_URL="https://binaries.soliditylang.org/bin/soljson-v0.1.1+commit.6ff4cd6.js"
COMPILER_FILE="soljson-v0.1.1.js"
SOURCE_FILE="FunDistributor.sol"
EXPECTED_SHA256="29fef67c6a7d76329a7d3e7770a9b08ae7705553ad628b4347123be0e2fed3c5"

echo "=== FunDistributor Bytecode Verification ==="
echo "Contract: $CONTRACT"
echo ""

# Download compiler if not present
if [ ! -f "$COMPILER_FILE" ]; then
    echo "Downloading soljson v0.1.1..."
    curl -sL "$COMPILER_URL" -o "$COMPILER_FILE"
fi

# Compile
echo "Compiling $SOURCE_FILE with soljson v0.1.1 (optimizer disabled)..."
COMPILED=$(node -e "
const solc = require('./$COMPILER_FILE');
const src = require('fs').readFileSync('$SOURCE_FILE', 'utf8');
const out = solc.compile(src, 0); // 0 = optimizer disabled
const contract = JSON.parse(out).contracts['FunDistributor'];
if (!contract) { console.error('Compilation failed'); process.exit(1); }
process.stdout.write(contract.runtimeBytecode);
")

echo "Compiled bytecode: 0x${COMPILED:0:40}..."
echo ""

# SHA256 check
COMPILED_SHA=$(echo -n "$COMPILED" | shasum -a 256 | cut -d' ' -f1)
echo "SHA256 of compiled bytecode: $COMPILED_SHA"
echo "Expected:                    $EXPECTED_SHA256"

if [ "$COMPILED_SHA" = "$EXPECTED_SHA256" ]; then
    echo ""
    echo "SHA256 MATCH"
else
    echo ""
    echo "SHA256 MISMATCH"
    exit 1
fi

# On-chain comparison (optional)
if [ -n "${ETHERSCAN_API_KEY:-}" ]; then
    echo ""
    echo "Fetching on-chain bytecode from Etherscan..."
    ONCHAIN=$(curl -s "https://api.etherscan.io/api?module=proxy&action=eth_getCode&address=$CONTRACT&tag=latest&apikey=$ETHERSCAN_API_KEY" | node -e "
        const d = require('fs').readFileSync('/dev/stdin','utf8');
        const r = JSON.parse(d).result;
        process.stdout.write(r.startsWith('0x') ? r.slice(2) : r);
    ")

    if [ "$COMPILED" = "$ONCHAIN" ]; then
        echo "ON-CHAIN BYTECODE MATCH (byte-for-byte)"
    else
        echo "ON-CHAIN BYTECODE MISMATCH"
        echo "Compiled length: ${#COMPILED}"
        echo "On-chain length: ${#ONCHAIN}"
        exit 1
    fi
else
    echo ""
    echo "Set ETHERSCAN_API_KEY to also verify against on-chain bytecode."
fi
