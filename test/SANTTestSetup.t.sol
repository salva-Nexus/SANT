// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { SANT } from "../src/Sant.sol";
import { SantVault } from "../src/SantVault.sol";
import { BaseTest } from "./BaseTest.t.sol";
import { Test, console } from "forge-std/Test.sol";

abstract contract SANTTestSetup is Test, BaseTest {
    function setUp() public {
        // Deploy the contract with admin, minter, and 100M minted to admin
        vm.startPrank(admin);
        sant = new SANT(admin, minter, INITIAL_MINT);
        santVault = new SantVault(address(sant), admin);
        sant.approve(address(santVault), INITIAL_DEPOSIT);
        santVault.deposit(INITIAL_DEPOSIT);
        vm.stopPrank();
    }
}
