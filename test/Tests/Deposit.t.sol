// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SANTTestSetup } from "../SANTTestSetup.t.sol";
import { console } from "forge-std/console.sol";

contract Deposit is SANTTestSetup {
    function test_NoRevenue() external {
        address[] memory users = new address[](3);
        users[0] = user1;
        users[1] = user2;
        users[2] = user3;

        vm.startPrank(admin);
        for (uint256 i = 0; i < users.length;) {
            sant.transfer(users[i], 10_000_000e18);
            unchecked {
                i++;
            }
        }
        vm.stopPrank();

        uint256 num = 2;
        for (uint256 i = 0; i < users.length;) {
            uint256 value = 10_000_000e18 / num;
            vm.startPrank(users[i]);
            sant.approve(address(santVault), value);
            santVault.deposit(value);
            vm.stopPrank();
            unchecked {
                num++;
                i++;
            }
        }
        // each SVT still 1:1
        assertEq(santVault.totalSantReserves(), santVault.totalSvtSupply());
        assertEq(santVault.exchangeRate(), 1e18);

        console.log("================BEFORE INJECTION=================");
        console.log("ExRate: ", santVault.exchangeRate());
        for (uint256 i = 0; i < users.length;) {
            console.log("User ", i + 1, "Receives: ", santVault.previewWithdrawAll(users[i]));
            unchecked {
                i++;
            }
        }

        uint256[] memory usersCachedBalannce = new uint256[](3);
        uint256 checkSum = santVault.previewWithdrawAll(admin);
        for (uint256 i = 0; i < users.length;) {
            usersCachedBalannce[i] = santVault.previewWithdrawAll(users[i]);
            checkSum += santVault.previewWithdrawAll(users[i]);
            unchecked {
                i++;
            }
        }
        assertLe(checkSum, santVault.totalSantReserves());
        _test_RevenueInjected(usersCachedBalannce, users);
    }

    function _test_RevenueInjected(uint256[] memory cachedBalance, address[] memory users)
        internal
    {
        uint256 value = 4500e18;
        vm.startPrank(admin);
        sant.approve(address(santVault), value);
        santVault.depositRevenue(value);
        vm.stopPrank();

        console.log("=================AFTER INJECTION=================");
        console.log("New ExRate: ", santVault.exchangeRate());
        for (uint256 i = 0; i < users.length;) {
            console.log("User ", i + 1, "Now Receives: ", santVault.previewWithdrawAll(users[i]));
            unchecked {
                i++;
            }
        }

        // each SVT now worth more
        uint256[] memory newCachedBalance = new uint256[](3);
        uint256 checkSum = santVault.previewWithdrawAll(admin);
        for (uint256 i = 0; i < users.length;) {
            assertGt(santVault.previewWithdrawAll(users[i]), cachedBalance[i]);
            newCachedBalance[i] += santVault.previewWithdrawAll(users[i]);
            checkSum += santVault.previewWithdrawAll(users[i]);
            unchecked {
                i++;
            }
        }

        assertLe(checkSum, santVault.totalSantReserves());
        _sideWayDepositDoesNotAffectShares(newCachedBalance, users);
    }

    function _sideWayDepositDoesNotAffectShares(uint256[] memory newCached, address[] memory users)
        internal
    {
        uint256 value = 10_000e18;
        vm.startPrank(admin);
        sant.transfer(address(santVault), value);
        vm.stopPrank();

        assertNotEq(santVault.totalSantReserves(), sant.balanceOf(address(santVault)));

        for (uint256 i = 0; i < users.length;) {
            assertEq(santVault.previewWithdrawAll(users[i]), newCached[i]);
            unchecked {
                i++;
            }
        }

        assertEq(
            santVault.totalSvtSupply(),
            santVault.svtBalanceOf(user1) + santVault.svtBalanceOf(user2)
                + santVault.svtBalanceOf(user3) + santVault.svtBalanceOf(admin)
        );
        _newDepositAfterRateAppreciation();
    }

    function _newDepositAfterRateAppreciation() internal {
        address newUser = makeAddr("newUser");
        address[] memory users = new address[](5);
        users[0] = user1;
        users[1] = user2;
        users[2] = user3;
        users[3] = admin;
        users[4] = newUser;
        uint256 value = 34000e18;

        vm.startPrank(admin);
        sant.transfer(newUser, value);
        vm.stopPrank();

        vm.startPrank(newUser);
        sant.approve(address(santVault), value);
        santVault.deposit(value);
        vm.stopPrank();

        console.log("===============AFTER NEW DEPOSIT===============");
        console.log("New User SVT: ", santVault.svtBalanceOf(newUser));
        console.log("New Total SVT Supply: ", santVault.totalSvtSupply());

        console.log("==========CHECKING EACH PERCENT SHARE==========");
        uint256 checkSum;
        uint256[] memory percentages = new uint256[](5);
        for (uint256 i = 0; i < users.length;) {
            console.log("User", i + 1, "BPS: ", santVault.ownershipBps(users[i]));
            checkSum += santVault.ownershipBps(users[i]);
            percentages[i] = santVault.ownershipBps(users[i]);
            unchecked {
                i++;
            }
        }

        console.log("Percentage Checksum: ", checkSum);
        assertLe(checkSum, 10_000e18);

        _checkNewPercentageAfterNewDeposit(users, percentages);
    }

    function _checkNewPercentageAfterNewDeposit(
        address[] memory eUser,
        uint256[] memory ePercentage
    ) internal {
        address newUser = makeAddr("newUser0");
        uint256 value = 60000e18;
        vm.startPrank(admin);
        sant.transfer(newUser, value);
        vm.stopPrank();

        vm.startPrank(newUser);
        sant.approve(address(santVault), value);
        santVault.deposit(value);
        vm.stopPrank();

        console.log("==========CHECKING EACH NEW PERCENT SHARE==========");
        uint256 checkSum;
        console.log("User 0 Prev %: 0");
        console.log("User 0 New %: ", santVault.ownershipBps(newUser));
        console.log("===================================================");
        for (uint256 i = 0; i < eUser.length;) {
            uint256 prevPercentage = ePercentage[i];
            uint256 newPercentage = santVault.ownershipBps(eUser[i]);
            console.log("User", i + 1, "Prev %: ", prevPercentage);
            console.log("User", i + 1, "New %: ", newPercentage);
            assertLe(newPercentage, prevPercentage);
            console.log("===================================================");
            checkSum += newPercentage;
            unchecked {
                i++;
            }
        }

        checkSum += santVault.ownershipBps(newUser);
        assertLe(checkSum, 10_000e18);
    }
}
