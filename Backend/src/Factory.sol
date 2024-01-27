// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {VaultWithFee} from "./VaultContractFees.sol";
import "hardhat/console.sol";

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

        bytes memory endOutput = abi.encodePacked(bytecode,abi.encode(asset,basisPoint,treasury,address(this)));
        
        bytes32 salt = keccak256(abi.encodePacked(asset,basisPoint,treasury,address(this)));
        
        assembly {
            vault := create2(0,add(endOutput,32),mload(endOutput),salt)
            if iszero(extcodesize(vault)) { revert(0, 0) }
        }

        console.log(vault);
        // assert(VaultWithFee(vault).asset() == asset);

        allVaults.push(vault);
        tokenToVault[asset] = vault;

    }

    function getCreationBytecode(address asset, uint _foo) public pure returns (bytes memory) {
        bytes memory bytecode = type(VaultWithFee).creationCode;

        return abi.encodePacked(bytecode, abi.encode(asset, _foo));
    }

    function requestFlashLoan(address asset, uint256 amount ,address receiver) public {
        uint256 x = VaultWithFee(tokenToVault[asset]).entryFeeBasisPoints();
        VaultWithFee(tokenToVault[asset]).FlashLoan(receiver, amount, x);
    }
}
