## Overview

This is a project to practice implementing a simple ERC20 token.

## Reference

- The original practice project is from [Chi-AnTai/ERC20-practice](https://github.com/Chi-AnTai/ERC20-practice)
- [ERC-20: Token Standard](https://eips.ethereum.org/EIPS/eip-20)
- [Solidity](https://soliditylang.org/)
- [Foundry Book](https://book.getfoundry.sh/)

## Script

### Foundry Basic Infomation

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy on sepolia

```shell
$ forge create --rpc-url https://ethereum-sepolia.publicnode.com \
    --constructor-args "your name" "your symbol" \
    --private-key "your private-key (sepolia chain)" \
    --etherscan-api-key "your etherscan-api-key" \
    --verify \
    src/TestERC20.sol:TestERC20
```

Then you can see your contract on **https://sepolia.etherscan.io/address/${your contract address}**.

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
