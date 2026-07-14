// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SANT } from "../src/SANT.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract DeploySANT is Script {
    function run() external returns (SANT) {
        // Let's mint 500 Million $SANT to the owner on deployment
        uint256 initialSupplyToMint = 500_000_000 * 10 ** 18;

        vm.startBroadcast();

        SANT sant =
            new SANT(address(0x8d7050a29C112638F0c9E0F103F3C498C2Bd948b), initialSupplyToMint);

        vm.stopBroadcast();

        console.log("$SANT deployed at:", address(sant));
        console.log("Initial Owner:", msg.sender);
        console.log("Total Supply minted:", sant.totalSupply() / 10 ** 18, "SANT");

        return sant;
    }
}
