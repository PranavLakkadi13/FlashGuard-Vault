// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";
import {MockBTC} from "../src/Asset.sol";
import {VaultWithFee} from "../src/VaultContractFees.sol";
import {Treasury} from "../src/Treasury.sol";

contract TestVault is Test {
    Factory public factory;
    MockBTC public btc;
    Treasury public treasury;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() external {
        vm.prank(bob);
        factory = new Factory();
        btc = new MockBTC();
        treasury = new Treasury();
    }

    function testCreateVault() external {
        vm.prank(bob);
        factory.createVault(address(0x1), 100, address(0));
    }

    function testVault() public {
        address x = factory.createVault(address(btc), 100,address(treasury));
        assertEq(address(btc), VaultWithFee(x).asset());
    }
}
