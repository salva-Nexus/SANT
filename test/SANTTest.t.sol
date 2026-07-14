// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { SANT } from "../src/Sant.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { Test, console } from "forge-std/Test.sol";

contract SANTTest is Test {
    using MessageHashUtils for bytes32;
    SANT public sant;

    // Defined Roles matching SANT.sol
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Test Addresses
    address public admin = address(0x1);
    address public minter = address(0x4); // Dedicated backend minter wallet
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    uint256 public constant INITIAL_MINT = 100_000_000 * 10 ** 18;
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    // Error definitions to test AccessControl Custom Error Selectors
    error SANT__ExceedsMaxSupply(uint256 requested, uint256 maxAllowed);
    error SANT__InvalidMintRecipient();
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    function setUp() public {
        // Deploy the contract with admin, minter, and 100M minted to admin
        vm.prank(admin);
        sant = new SANT(admin, minter, INITIAL_MINT);
    }

    /* ---------------- Initial State Tests ---------------- */

    function test_InitialSetup() public view {
        assertEq(sant.name(), "Salva Nexus Token");
        assertEq(sant.symbol(), "SANT");
        assertEq(sant.totalSupply(), INITIAL_MINT);
        assertEq(sant.balanceOf(admin), INITIAL_MINT);

        // Assert Role Configuration
        assertTrue(sant.hasRole(DEFAULT_ADMIN_ROLE, admin));
        assertTrue(sant.hasRole(MINTER_ROLE, minter));
        assertFalse(sant.hasRole(MINTER_ROLE, user1));
    }

    /* ---------------- Minting & Access Control ---------------- */

    function test_MinterCanMint() public {
        uint256 mintAmount = 50_000 * 10 ** 18;

        vm.prank(minter);
        sant.mint(user1, mintAmount);

        assertEq(sant.balanceOf(user1), mintAmount);
        assertEq(sant.totalSupply(), INITIAL_MINT + mintAmount);
    }

    function test_NonMinterCannotMint() public {
        vm.prank(user1);

        // Expecting OpenZeppelin's custom AccessControl unauthorized error
        vm.expectRevert(
            abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, user1, MINTER_ROLE)
        );
        sant.mint(user1, 1000 * 10 ** 18);
    }

    function test_MintFailsIfExceedsMaxSupply() public {
        // Attempting to mint over the remaining 900M supply
        uint256 excessMint = (MAX_SUPPLY - INITIAL_MINT) + 1;

        vm.prank(minter);
        vm.expectRevert(
            abi.encodeWithSelector(
                SANT__ExceedsMaxSupply.selector, INITIAL_MINT + excessMint, MAX_SUPPLY
            )
        );
        sant.mint(user1, excessMint);
    }

    function test_CannotMintToZeroAddress() public {
        vm.prank(minter);
        vm.expectRevert(SANT__InvalidMintRecipient.selector);
        sant.mint(address(0), 100 * 10 ** 18);
    }

    /* ---------------- Gasless Permitting (EIP-2612) ---------------- */

    function test_PermitSignatures() public {
        // Set up a structured key pair to generate EIP-712 signatures
        uint256 privateKey = 0xA11CE;
        address alice = vm.addr(privateKey);

        // Fund Alice with some SANT first (from admin's initial mint)
        vm.prank(admin);
        sant.transfer(alice, 1000 * 10 ** 18);

        uint256 value = 500 * 10 ** 18;
        uint256 deadline = block.timestamp + 1 days;
        uint256 nonce = sant.nonces(alice);

        // Build the Domain Separator / Digest
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                ),
                alice,
                user1,
                value,
                nonce,
                deadline
            )
        );
        bytes32 digest = sant.DOMAIN_SEPARATOR().toTypedDataHash(structHash);

        // Sign the data using Foundry's cryptographic utility cheatcode
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        // Execute permit. Anyone can submit this on behalf of Alice (e.g. your gasless paymaster!)
        sant.permit(alice, user1, value, deadline, v, r, s);

        // Check that authorization completed successfully
        assertEq(sant.allowance(alice, user1), value);
        assertEq(sant.nonces(alice), nonce + 1);
    }
}
