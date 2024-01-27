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

    function createVault(address asset,uint256 basisPoint,address treasury) external returns (address vault) {
        if (asset == address(0)) {
            revert Factory__InvaildAsset();
        }
        if (tokenToVault[asset] != address(0)) {
            revert Factory__VaultExists();
        }
        bytes memory bytecode = type(VaultWithFee).creationCode;

        bytes memory endOutput = abi.encodePacked(bytecode,abi.encode(asset,basisPoint,treasury));
        
        bytes32 salt = keccak256(abi.encodePacked(asset));
        
        assembly {
            vault := create2(0,add(endOutput,32),mload(endOutput),salt)
        }

        // assert(VaultWithFee(vault).asset() == asset);

        allVaults.push(vault);
        tokenToVault[asset] = vault;

    }

    function getCreationBytecode(address asset, uint _foo) public pure returns (bytes memory) {
        bytes memory bytecode = type(VaultWithFee).creationCode;

        return abi.encodePacked(bytecode, abi.encode(asset, _foo));
    }
}
