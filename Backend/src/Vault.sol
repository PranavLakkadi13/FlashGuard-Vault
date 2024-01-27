// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {ERC4626,IERC20Metadata,ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract Vault is ERC4626 {
    constructor(IERC20Metadata _asset) ERC4626(_asset) ERC20("Vault Token","VLT"){

    }
}