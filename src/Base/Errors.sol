// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Errors {
    error Errors__ZeroAmount();
    error Errors__InsufficientSVT();
    error Errors__NotAuthorized();
    error Errors__ZeroAddress();
    error Errors__VaultPaused();
    error Errors__NoSVTMinted();
    error Errors__CooldownNotElapsed();
}
