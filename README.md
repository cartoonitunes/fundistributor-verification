# FunDistributor Bytecode Verification

**Contract:** [`0x125b606c67e8066da65069652b656c19717745fa`](https://etherscan.io/address/0x125b606c67e8066da65069652b656c19717745fa)
**Deployed:** August 10, 2015 (block 62,632)
**Compiler:** soljson v0.1.1+commit.6ff4cd6 (optimizer disabled)
**SHA256:** `29fef67c6a7d76329a7d3e7770a9b08ae7705553ad628b4347123be0e2fed3c5`

## Overview

FunDistributor is a "king of the hill" behavioral economics experiment deployed 11 days after Ethereum mainnet launch. Players compete to become the `receiver` by sending more than 1% of the contract's current balance via `touch()`. If nobody touches the contract for 200+ blocks (~45 minutes), the current receiver is paid out 1/3 of the balance. The touch interval grows by 0.5% after each payout round, gradually slowing the game.

**Reddit announcement:** [Contract for exploring behavioral economics and game theory](https://www.reddit.com/r/ethereum/comments/3gfxus/contract_for_exploring_behavioral_economics_and/)

## Source Recovery

The original source was hosted on [Pastebin](http://pastebin.com/0DKLWiuc) (now expired). This source code was reconstructed entirely from on-chain bytecode through compiler archaeology - testing every early Solidity compiler version until achieving a byte-for-byte match.

## Verification

```bash
chmod +x verify.sh
./verify.sh

# With on-chain comparison:
ETHERSCAN_API_KEY=your_key ./verify.sh
```

The script downloads soljson v0.1.1, compiles `FunDistributor.sol` with optimizer disabled, and compares the output against the expected SHA256 hash. Optionally fetches on-chain bytecode from Etherscan for direct comparison.

## Notable Findings

### The `private` keyword in solc 0.1.1

The `payout()` function is declared `private` - one of the earliest known uses of function visibility in a deployed contract. In solc 0.1.1, `private` excludes the function from the dispatch table (no selector generated), making it callable only internally. This keyword was supported but rarely seen in contracts from this era.

### Reddit vs. reality: 25% or 33%?

The [Reddit post](https://www.reddit.com/r/ethereum/comments/3gfxus/contract_for_exploring_behavioral_economics_and/) described the payout as "approximately 25% of the balance." The verified source code shows `this.balance / 3` - a 33.3% payout. Whether this was a documentation error or a last-minute code change is unknown.

### Operand order affects bytecode

solc 0.1.1 evaluates binary expressions right-to-left. `msg.value * 100` and `100 * msg.value` produce different bytecode due to different PUSH/CALLVALUE ordering. Matching the correct operand order was critical to achieving a byte-for-byte match.

## Contract Mechanics

| Function | Description |
|---|---|
| `touch()` | Send ETH to compete. If `msg.value * 100 > balance`, you become the receiver. Otherwise, your ETH is refunded. Also triggers payout check. |
| `get_receiver()` | Returns the current receiver address. |
| `get_target_block()` | Returns the block number at which payout becomes available. |
| `get_touch_interval()` | Returns the current touch interval (starts at 200, grows 0.5% per round). |
| `payout()` (private) | If `block.number > lastBlock + touchInterval`, sends 1/3 of balance to receiver and increases interval. |

## Links

- [Ethereum History](https://ethereumhistory.com/contract/0x125b606c67e8066da65069652b656c19717745fa)
- [Etherscan](https://etherscan.io/address/0x125b606c67e8066da65069652b656c19717745fa)
- [Reddit announcement](https://www.reddit.com/r/ethereum/comments/3gfxus/contract_for_exploring_behavioral_economics_and/)
- [awesome-ethereum-proofs](https://github.com/cartoonitunes/awesome-ethereum-proofs)

## License

[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) - Public domain.
