// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Storage {
    address public immutable SANT;
    address public immutable MULTISIG;

    // Total SANT currently held by the vault, backing all outstanding SVT.
    uint256 internal _santReserves;

    // Total SVT (Salva Vault Token) minted across all stakers.
    uint256 internal _svtSupply;

    uint256 internal constant SCALING_PRECISION = 1e18;
    uint256 internal constant BPS_DENOMINATOR = 10_000;
    uint256 internal constant WITHDRAWAL_COOLDOWN = 7 days;

    bool internal paused;

    struct StakerInfo {
        uint256 svtBalance;
        uint256 depositTimestamp;
    }

    mapping(address => StakerInfo) internal _stakers;
}
