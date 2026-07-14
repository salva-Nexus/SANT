// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { SANT } from "../src/SANT.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { Test, console } from "forge-std/Test.sol";

contract SANTTest is Test {
    using MessageHashUtils for bytes32;
    SANT public sant;

    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    uint256 public constant INITIAL_MINT = 100_000_000 * 10 ** 18;
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    // Error definitions to test Custom Error Selectors
    error SANT__ExceedsMaxSupply(uint256 requested, uint256 maxAllowed);
    error SANT__InvalidMintRecipient();
    error OwnableUnauthorizedAccount(address account);

    function setUp() public {
        // Deploy the contract with 100M minted to owner
        vm.prank(owner);
        sant = new SANT(owner, INITIAL_MINT);
    }

    /* ---------------- Initial State Tests ---------------- */

    function test_InitialSetup() public view {
        assertEq(sant.name(), "Salva Nexus Token");
        assertEq(sant.symbol(), "SANT");
        assertEq(sant.owner(), owner);
        assertEq(sant.totalSupply(), INITIAL_MINT);
        assertEq(sant.balanceOf(owner), INITIAL_MINT);
    }

    /* ---------------- Minting & Custom Errors ---------------- */

    function test_OwnerCanMint() public {
        uint256 mintAmount = 50_000 * 10 ** 18;

        vm.prank(owner);
        sant.mint(user1, mintAmount);

        assertEq(sant.balanceOf(user1), mintAmount);
        assertEq(sant.totalSupply(), INITIAL_MINT + mintAmount);
    }

    function test_NonOwnerCannotMint() public {
        vm.prank(user1);
        // Expecting OpenZeppelin's custom ownable error
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, user1));
        sant.mint(user1, 1000 * 10 ** 18);
    }

    function test_MintFailsIfExceedsMaxSupply() public {
        // Attempting to mint over the remaining 900M supply
        uint256 excessMint = (MAX_SUPPLY - INITIAL_MINT) + 1;

        vm.prank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(
                SANT__ExceedsMaxSupply.selector, INITIAL_MINT + excessMint, MAX_SUPPLY
            )
        );
        sant.mint(user1, excessMint);
    }

    function test_CannotMintToZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(SANT__InvalidMintRecipient.selector);
        sant.mint(address(0), 100 * 10 ** 18);
    }

    /* ---------------- Gasless Permitting (EIP-2612) ---------------- */

    function test_PermitSignatures() public {
        // Set up a structured key pair to generate EIP-712 signatures
        uint256 privateKey = 0xA11CE;
        address alice = vm.addr(privateKey);

        // Fund Alice with some SANT first
        vm.prank(owner);
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
