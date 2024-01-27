// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {MockBTC} from "../src/Asset.sol";
import {VaultWithFee} from "../src/VaultContractFees.sol";

contract TestFactory is Test {

    Factory public factory;
    MockBTC public btc;

    function setUp() public {
        factory = new Factory();
        btc = new MockBTC();
    }

    function testCreateVault() public {
        address x = factory.createVault(address(btc),100,address(0));
        assertEq(VaultWithFee(x).asset(), address(btc));
    }
}