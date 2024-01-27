// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Factory} from "../src/Factory.sol";

contract TestVault is Test {
    Factory public factory;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() external {
        factory = new Factory();
    }

    function testCreateVault() external {
        vm.prank(bob);
        factory.createVault(address(0x1), 100, address(0));
    }
}
