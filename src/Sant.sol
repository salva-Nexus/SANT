// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title Salva Nexus Token ($SANT)
 * @author cboi@Salva
 * @notice Standard ERC20 token with EIP-2612 Permit for gasless transactions,
 * and role-based minting control using custom error selectors instead of require statements.
 */
contract SANT is ERC20, ERC20Permit, AccessControl {
    // Max supply hardcap: 1 Billion $SANT (1,000,000,000 * 10^18)
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    // Define the specific role needed to mint tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    error SANT__ExceedsMaxSupply(uint256 requested, uint256 maxAllowed);
    error SANT__InvalidMintRecipient();

    constructor(address defaultAdmin, address initialMinter, uint256 initialSupplyToMint)
        ERC20("Salva Nexus Token", "SANT")
        ERC20Permit("Salva Nexus Token")
    {
        if (initialSupplyToMint > MAX_SUPPLY) {
            revert SANT__ExceedsMaxSupply(initialSupplyToMint, MAX_SUPPLY);
        }

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, initialMinter);

        if (initialSupplyToMint > 0) {
            _mint(defaultAdmin, initialSupplyToMint);
        }
    }

    /**
     * @notice Allows accounts with the MINTER_ROLE to mint new tokens up to the MAX_SUPPLY.
     * @dev Restricted via AccessControl's onlyRole modifier.
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        if (to == address(0)) {
            revert SANT__InvalidMintRecipient();
        }
        if (totalSupply() + amount > MAX_SUPPLY) {
            revert SANT__ExceedsMaxSupply(totalSupply() + amount, MAX_SUPPLY);
        }
        _mint(to, amount);
    }
}
