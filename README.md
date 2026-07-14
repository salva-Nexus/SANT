# Salva Nexus Token (SANT)

The **Salva Nexus Token ($SANT)** is the native utility and rewards token powering the **Salva Nexus** ecosystem.

Unlike traditional token launches, **$SANT is designed to be earned through real network usage**, not sold through public presales. Users participate in the growth of the ecosystem by using Salva's payment infrastructure, gradually earning ownership in the network they help build.

---

## Vision

Salva Nexus is building payment infrastructure that makes stablecoin transfers and P2P exchange feel seamless.

The long-term vision is simple:

> **Use the network. Earn the network.**

As users make transfers, perform swaps, receive payments, and contribute liquidity, they earn **$SANT**, representing participation in the ecosystem. As the network matures, $SANT holders will be able to stake their tokens and earn a share of protocol-generated revenue.

---

## Features

- ERC-20 compliant
- EIP-2612 Permit (gasless approvals)
- Role-based minting
- Hard capped supply of **1,000,000,000 SANT**
- Built with OpenZeppelin Contracts

---

## Token Information

| Property | Value |
|----------|-------|
| Name | Salva Nexus Token |
| Symbol | SANT |
| Decimals | 18 |
| Standard | ERC-20 |
| Permit | EIP-2612 |
| Maximum Supply | 1,000,000,000 SANT |

---

## Deployments

### Base Mainnet

| Contract | Address |
|----------|---------|
| SANT | `0xdC6790528ea33D61C573F0Ae9317773621B23D18` |

### Base Sepolia

| Contract | Address |
|----------|---------|
| SANT | `0x7ED077E471E9895061F2bbe8E4D00396E7236DBe` |

---

## Utility

$SANT serves as the economic layer of the Salva ecosystem.

Planned utilities include:

- Mining rewards for network usage
- Protocol staking
- Revenue sharing from protocol fees
- Ecosystem incentives
- Future governance (subject to ecosystem evolution)

---

## Reward Philosophy

Salva follows a simple principle:

> **Real usage should create real ownership.**

Instead of rewarding speculation, the protocol rewards users who actively contribute to network growth.

Examples of rewardable actions include:

- Sending stablecoins
- Receiving stablecoins
- Swapping assets
- Providing liquidity
- Using Salva ecosystem services

The reward engine operates independently of this ERC-20 contract.

---

## Revenue Sharing

As the Salva payment network grows, a percentage of protocol-generated fees will be distributed to **staked SANT holders**.

The objective is to create sustainable, real yield backed by actual payment activities.

---

## Smart Contract Scope

This repository contains only the ERC-20 implementation of the Salva Nexus Token.

Responsibilities include:

- Token balances
- Transfers
- Minting
- Permit approvals

The following systems are intentionally implemented outside of this contract:

- Mining engine
- Reward distribution
- Staking
- Fee sharing
- Treasury management
- Salva Wallet integration

Keeping the token contract simple improves security, auditability, and long-term maintainability.

---

## Disclaimer

$SANT is a utility token designed for participation within the Salva ecosystem.

Ownership of $SANT does **not** represent equity, shares, or ownership in Salva Labs or any legal entity. Rights and utilities associated with the token are defined solely by the deployed smart contracts and protocol.

---

## License

Licensed under the MIT License.