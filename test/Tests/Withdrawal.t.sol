// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SANTTestSetup } from "../SANTTestSetup.t.sol";
import { Errors } from "@Errors/Errors.sol";
import { console } from "forge-std/console.sol";

contract Withdrawal is SANTTestSetup {
    function test_Withdrawal() external {
        address newUser = makeAddr("newUser");
        uint256 value = 30000e18;

        vm.startPrank(admin);
        sant.transfer(newUser, value);
        vm.stopPrank();

        vm.startPrank(newUser);
        sant.approve(address(santVault), value);
        santVault.deposit(value);
        vm.stopPrank();

        _cannotWithdrawBeforeCooldown(newUser);
    }

    function _cannotWithdrawBeforeCooldown(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _cannotWithdrawAfter5mins(user);
    }

    function _cannotWithdrawAfter5mins(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 300); // 5 mins
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _cannotWithdrawAfter30min(user);
    }

    function _cannotWithdrawAfter30min(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 1800); // 30 mins
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _cannotWithdrawAfter24Hours(user);
    }

    function _cannotWithdrawAfter24Hours(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 24 hours); // 24 Hours
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _cannotWithdrawAfter6Days(user);
    }

    function _cannotWithdrawAfter6Days(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 5 days);
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _newDepositAffectsDepositTimestamp(user); // pushes deposit time forward,
        // making user hold longer if they try to deposit big to get bigger share and withdraw at
        // once
    }

    function _newDepositAffectsDepositTimestamp(address user) internal {
        // User is meant to be able to withdraw in the next 24HOURS
        // But with a new deposit, it should prolong it the more
        uint256 newValue = 60000e18;

        vm.startPrank(admin);
        sant.transfer(user, newValue);
        vm.stopPrank();

        vm.startPrank(user);
        sant.approve(address(santVault), newValue);
        santVault.deposit(newValue);

        uint256 value = santVault.svtBalanceOf(user);
        console.log("New SVT Balance", value);
        vm.warp(block.timestamp + 24 hours);
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _testAnother1Second(user);
    }

    function _testAnother1Second(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 1); // 1 Second
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _testAnother24Hours(user);
    }

    function _testAnother24Hours(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 24 hours); // 24hours
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _testAnother24Hours1(user);
    }

    function _testAnother24Hours1(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 24 hours); // 24hours
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _testAnother24Hours2(user);
    }

    function _testAnother24Hours2(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 24 hours); // 24hours
        vm.expectRevert(Errors.Errors__CooldownNotElapsed.selector);
        santVault.withdraw(value);
        vm.stopPrank();

        _testAnother48Hours(user);
    }

    function _testAnother48Hours(address user) internal {
        uint256 value = santVault.svtBalanceOf(user);
        vm.startPrank(user);
        vm.warp(block.timestamp + 48 hours); // 48 hours
        // Should work now
        santVault.withdraw(value);
        vm.stopPrank();

        assertEq(santVault.svtBalanceOf(user), 0);
    }
}
