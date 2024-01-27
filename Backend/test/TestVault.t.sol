// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Factory} from "../src/Factory.sol";
import {MockBTC} from "../src/Asset.sol";
import {VaultWithFee} from "../src/VaultContractFees.sol";
import {Treasury} from "../src/Treasury.sol";
import {FlashLoanTest} from "../src/flashLoanTest.sol";

contract TestVault is Test {
    Factory public factory;
    MockBTC public btc;
    Treasury public treasury;
    FlashLoanTest public loanvault;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() external {
        vm.startPrank(bob);
        factory = new Factory();
        btc = new MockBTC();
        treasury = new Treasury();
        loanvault = new FlashLoanTest(address(factory));
        vm.stopPrank();
    }

    function testCreateVault() external {
        vm.prank(bob);
        factory.createVault(address(0x1), 100, address(0));
    }

    function testVault() public {
        address x = factory.createVault(address(btc), 100,address(treasury));
        assertEq(address(btc), VaultWithFee(x).asset());
    }

    function testVaultDeposit() public {
        vm.startPrank(bob);
        address x = factory.createVault(address(btc), 100,address(treasury));
        assertEq(address(btc), VaultWithFee(x).asset());
        btc.approve(x, 100e18);
        btc.transfer(address(loanvault), 100e18);
        VaultWithFee(x).deposit(100e18, bob);
        vm.stopPrank();

        uint256 bal = btc.balanceOf(x);
        console.log(bal);
        btc.balanceOf(address(treasury));

        VaultWithFee(x).balanceOf(bob);

        loanvault.requestFlashLoan(address(btc),98e18);

        
        // factory.requestFlashLoan(address(btc),90e18,address(loanvault));
    }
}
