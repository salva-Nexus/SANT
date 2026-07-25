// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Modifiers } from "@Modifiers/Modifiers.sol";

abstract contract VaultData is Modifiers {
    // ── SANT redeemable per 1 SVT, scaled by 1e18
    // ───────────────────────────────
    function exchangeRate() public view returns (uint256 rate) {
        if (_svtSupply == 0) return 0;
        rate = (_santReserves * SCALING_PRECISION) / _svtSupply;
    }

    // ── SANT a user would receive for redeeming their ENTIRE SVT balance ───────
    function previewWithdrawAll(address user) public view returns (uint256 santOut) {
        if (_svtSupply == 0) return 0;
        santOut = (svtBalanceOf(user) * _santReserves) / _svtSupply;
    }

    // ── SANT that would be received for redeeming a specific SVT amount
    // ────────
    function previewWithdraw(uint256 svtToBurn) public view returns (uint256 santOut) {
        if (_svtSupply == 0) return 0;
        santOut = (svtToBurn * _santReserves) / _svtSupply;
    }

    // ── SVT that would be minted for a hypothetical SANT deposit
    // ───────────────
    function previewDeposit(uint256 santAmount) public view returns (uint256 svtOut) {
        if (_svtSupply == 0) return santAmount;
        svtOut = (santAmount * _svtSupply) / _santReserves;
    }

    // ── Total SVT minted across all stakers
    // ─────────────────────────────────────
    function totalSvtSupply() public view returns (uint256) {
        return _svtSupply;
    }

    // ── Total SANT currently held by the vault
    // ──────────────────────────────────
    function totalSantReserves() public view returns (uint256) {
        return _santReserves;
    }

    // ── SVT balance held by a specific staker
    // ───────────────────────────────────
    function svtBalanceOf(address user) public view returns (uint256) {
        return _stakers[user].svtBalance;
    }

    // ── Ownership share of `user`, in bps scaled by 1e18
    // ────────────────────────
    // (off-chain: divide by 1e18 for bps, then by 100 for a human percentage)
    function ownershipBps(address user) public view returns (uint256 shareBps) {
        if (_svtSupply == 0) return 0;
        shareBps = (svtBalanceOf(user) * BPS_DENOMINATOR * SCALING_PRECISION) / _svtSupply;
    }

    // ── Blended deposit timestamp for a staker (cooldown reference point) ──────
    function depositTimestampOf(address user) public view returns (uint256) {
        return _stakers[user].depositTimestamp;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // INTERNAL CALCULATIONS
    // ─────────────────────────────────────────────────────────────────────────

    function _calculateSvtToMint(uint256 santAmount) internal view returns (uint256 svtToMint) {
        svtToMint = (santAmount * _svtSupply) / _santReserves;
    }

    function _calculateSantOut(uint256 svtToBurn) internal view returns (uint256 santOut) {
        santOut = (svtToBurn * _santReserves) / _svtSupply;
    }

    function _calculateNewDepositTimestamp(
        uint256 oldTimestamp,
        uint256 svtMinted,
        uint256 existingSvtBalance
    ) internal view returns (uint256 newTimestamp) {
        uint256 totalSvtAfter = svtMinted + existingSvtBalance;
        uint256 timeElapsed = block.timestamp - oldTimestamp;
        uint256 timeShift = (timeElapsed * svtMinted) / totalSvtAfter;
        newTimestamp = oldTimestamp + timeShift;
    }
}
