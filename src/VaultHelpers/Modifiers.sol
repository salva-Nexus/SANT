// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Context } from "@Context/Context.sol";
import { Errors } from "@Errors/Errors.sol";
import { Storage } from "@Storage/Storage.sol";

abstract contract Modifiers is Storage, Errors, Context {
    modifier onlyMultiSig() {
        if (_msgSender() != MULTISIG) revert Errors__NotAuthorized();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert Errors__VaultPaused();
        _;
    }
}
