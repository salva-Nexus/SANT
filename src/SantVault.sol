// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { VaultData } from "@VaultData/VaultData.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SantVault is VaultData {
    using SafeERC20 for IERC20;

    event Deposited(address indexed user, uint256 santIn, uint256 svtMinted);
    event Withdrawn(address indexed user, uint256 svtBurned, uint256 santOut);
    event RevenueInjected(address indexed caller, uint256 santAmount, uint256 newSantReserves);
    event PausedStateChanged(bool isPaused);

    constructor(address santToken, address multiSig) {
        if (santToken == address(0) || multiSig == address(0)) {
            revert Errors__ZeroAddress();
        }
        SANT = santToken;
        MULTISIG = multiSig;
    }

    function deposit(uint256 santAmount) public whenNotPaused {
        if (santAmount == 0) revert Errors__ZeroAmount();

        address sender = _msgSender();
        uint256 svtMinted = _svtSupply == 0 ? santAmount : _calculateSvtToMint(santAmount);

        StakerInfo storage staker = _stakers[sender];
        uint256 existingSvtBalance = staker.svtBalance;
        uint256 newTimestamp = staker.depositTimestamp == 0
            ? block.timestamp
            : _calculateNewDepositTimestamp(staker.depositTimestamp, svtMinted, existingSvtBalance);

        staker.svtBalance += svtMinted;
        staker.depositTimestamp = newTimestamp;
        _svtSupply += svtMinted;
        _santReserves += santAmount;

        IERC20(SANT).safeTransferFrom(sender, address(this), santAmount);

        emit Deposited(sender, santAmount, svtMinted);
    }

    function withdraw(uint256 svtToBurn) external whenNotPaused {
        if (svtToBurn == 0) revert Errors__ZeroAmount();
        if (_svtSupply == 0) revert Errors__NoSVTMinted();

        address sender = _msgSender();
        StakerInfo storage staker = _stakers[sender];

        if (staker.svtBalance < svtToBurn) revert Errors__InsufficientSVT();

        uint256 timeElapsed = block.timestamp - staker.depositTimestamp;
        if (timeElapsed < WITHDRAWAL_COOLDOWN) revert Errors__CooldownNotElapsed();

        uint256 santOut = _calculateSantOut(svtToBurn);

        staker.svtBalance -= svtToBurn;
        _svtSupply -= svtToBurn;
        _santReserves -= santOut;

        IERC20(SANT).safeTransfer(sender, santOut);

        emit Withdrawn(sender, svtToBurn, santOut);
    }

    function depositRevenue(uint256 santAmount) external {
        if (santAmount == 0) revert Errors__ZeroAmount();
        if (_svtSupply == 0) revert Errors__NoSVTMinted();

        IERC20(SANT).safeTransferFrom(_msgSender(), address(this), santAmount);
        _santReserves += santAmount;

        emit RevenueInjected(_msgSender(), santAmount, _santReserves);
    }

    function pauseProtocol() external onlyMultiSig {
        paused = true;
        emit PausedStateChanged(true);
    }

    function unpauseProtocol() external onlyMultiSig {
        paused = false;
        emit PausedStateChanged(false);
    }
}
