// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title Salva Nexus Token ($SANT)
 * @author cboi@Salva
 * @notice Standard ERC20 token with EIP-2612 Permit for gasless transactions,
 * burn capabilities for deflationary mechanics, and owner-controlled minting
 * using custom error selectors instead of require statements.
 */
contract SANT is ERC20, ERC20Permit, Ownable {
    // Max supply hardcap: 1 Billion $SANT (1,000,000,000 * 10^18)
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    error SANT__ExceedsMaxSupply(uint256 requested, uint256 maxAllowed);
    error SANT__InvalidMintRecipient();

    constructor(address initialOwner, uint256 initialSupplyToMint)
        ERC20("Salva Nexus Token", "SANT")
        ERC20Permit("Salva Nexus Token")
        Ownable(initialOwner)
    {
        if (initialSupplyToMint > MAX_SUPPLY) {
            revert SANT__ExceedsMaxSupply(initialSupplyToMint, MAX_SUPPLY);
        }

        if (initialSupplyToMint > 0) {
            _mint(initialOwner, initialSupplyToMint);
        }
    }

    function mint(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) {
            revert SANT__InvalidMintRecipient();
        }
        if (totalSupply() + amount > MAX_SUPPLY) {
            revert SANT__ExceedsMaxSupply(totalSupply() + amount, MAX_SUPPLY);
        }
        _mint(to, amount);
    }
}
