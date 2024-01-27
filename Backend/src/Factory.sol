// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {VaultWithFee} from "./VaultContractFees.sol";

contract Factory {
    mapping(address token => address vault) public tokenToVault;

    address[] public allVaults;

    ///Errors
    error Factory__InvaildAsset();
    error Factory__VaultExists();

    function getNumberOfVaults() external view returns (uint256) {
        return allVaults.length;
    }

    function createVault(address asset) external returns (address vault) {
        if (asset == address(0)) {
            revert Factory__InvaildAsset();
        }
        if (tokenToVault[asset] != address(0)) {
            revert Factory__VaultExists();
        }
    }
}
