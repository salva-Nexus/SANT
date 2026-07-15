// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SANT } from "../src/Sant.sol";
import { Script } from "forge-std/Script.sol";

contract TransferOwnership is Script {
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private constant BASE_CHAIN_ID = 8453;
    uint256 private constant BASE_SEPOLIA_CHAIN_ID = 84532;

    address private constant BASE_MAINNET_SANT = 0xCf1F78A58270cE1fE1239e475E8e767348377400;

    address private constant BASE_SEPOLIA_SANT = 0x7ED077E471E9895061F2bbe8E4D00396E7236DBe;

    function run() external {
        address newMinter = 0xfD5A9828bac27495FAb7F6174b3de386E0554187;

        vm.startBroadcast();

        if (block.chainid == BASE_CHAIN_ID) {
            SANT(BASE_MAINNET_SANT).grantRole(MINTER_ROLE, newMinter);
        } else if (block.chainid == BASE_SEPOLIA_CHAIN_ID) {
            SANT(BASE_SEPOLIA_SANT).grantRole(MINTER_ROLE, newMinter);
        } else {
            revert("Unsupported chain");
        }

        vm.stopBroadcast();
    }
}
