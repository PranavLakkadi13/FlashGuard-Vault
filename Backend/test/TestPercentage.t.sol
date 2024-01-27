// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {PercentageMath} from "../src/Percentage.sol";

contract TestPercentage is Test {
    using PercentageMath for uint256;

    //Addresses
    address bob = makeAddr("bob");
    address alicem = makeAddr("alice");

    //Variables
    uint256 value = 1000;

    function testPercentageMultiplication() external {
        uint256 x = (value).percentMul(1e2);
        assertEq(x, 10);
    }

    function testPercentDiv() external {
        uint256 x = (value).percentDiv(1e4);
        assertEq(x, 1000);
    }
}
