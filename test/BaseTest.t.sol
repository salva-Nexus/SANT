// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SANT } from "../src/Sant.sol";
import { SantVault } from "../src/SantVault.sol";

abstract contract BaseTest {
    SANT public sant;
    SantVault public santVault;

    // Defined Roles matching SANT.sol
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Test Addresses
    address public admin = address(0x1);
    address public minter = address(0x4); // Dedicated backend minter wallet
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public user3 = address(0x4);

    uint256 public constant INITIAL_MINT = 100_000_000 * 10 ** 18;
    uint256 public constant INITIAL_DEPOSIT = 1000 * 10 ** 18;
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    // Error definitions to test AccessControl Custom Error Selectors
    error SANT__ExceedsMaxSupply(uint256 requested, uint256 maxAllowed);
    error SANT__InvalidMintRecipient();
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
}
