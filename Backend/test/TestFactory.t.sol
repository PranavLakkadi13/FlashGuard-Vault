// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Factory} from "../src/VaultContract.sol";
contract TestFactory is Test {

    Factory public factory;

    function setUp() public {
        factory = new Factory();
    }

    function testCreateVault() public {
        factory.createVault(address(mockBtc),100,address(0));
    }
}