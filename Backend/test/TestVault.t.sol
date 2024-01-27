// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
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
        address x = factory.createVault(address(btc), 100, address(treasury));
        assertEq(address(btc), VaultWithFee(x).asset());
    }

    function testVaultDeposit() public {
        vm.startPrank(bob);
        address x = factory.createVault(address(btc), 100, address(treasury));
        assertEq(address(btc), VaultWithFee(x).asset());
        btc.approve(x, 100e18);
        btc.transfer(address(loanvault), 100e18);
        VaultWithFee(x).deposit(100e18, bob);
        vm.stopPrank();

        uint256 bal = btc.balanceOf(x);
        // console.log("Balance of Vault" + bal);
        console.log(string(abi.encodePacked("Balance of Vault :-               ")), bal);
        btc.balanceOf(address(treasury));

        uint256 tes = VaultWithFee(x).balanceOf(bob);
        // console.log("Number of Shares minted" + tes);
        console.log(string(abi.encodePacked("Number of Shares minted :-        ")), tes);
        loanvault.requestFlashLoan(address(btc), 98e18);

        uint256 bal2 = btc.balanceOf(x);
        console.log(string(abi.encodePacked("Balance after flash loan :-       ")), bal2);

        uint256 feeCollected = bal2 - bal;
        console.log(string(abi.encodePacked("Fee Collected from Flash loan :-  ")), feeCollected);

        vm.prank(bob);
        VaultWithFee(x).withdraw(tes, bob, bob);
        console.log(btc.balanceOf(bob));

        // factory.requestFlashLoan(address(btc),90e18,address(loanvault));
    }
}
