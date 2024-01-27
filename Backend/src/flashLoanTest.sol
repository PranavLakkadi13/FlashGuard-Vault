// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./IFlashLoanSimpleReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Factory} from "./Factory.sol";

contract FlashLoanTest is IFlashLoanSimpleReceiver {
    address payable owner;
    // IERC20 token;
    Factory factory;

    constructor(address afctory) {
        owner = payable(msg.sender);
        factory = Factory(afctory);
        // token = IERC20(token);
    }

    function executeOperation(address asset, uint256 amount, uint256 premium)
        external
        virtual
        override
        returns (bool)
    {
        //Here we already have the borrowed funds and the user needs to write the logic
        uint256 amountOwed = amount + premium;
        IERC20(asset).approve(address(owner), amountOwed);
        return true;
    }

    function requestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;

        // bytes memory params = ""; 
        // uint16 referralCode = 0;

        factory.requestFlashLoan(asset, amount, address(this));
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender,token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable{}
}