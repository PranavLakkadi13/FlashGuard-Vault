// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

<<<<<<< HEAD
import {Test} from ""
=======
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
>>>>>>> f45df2ffac8cd785bd38d1b8247c99f389750d24
