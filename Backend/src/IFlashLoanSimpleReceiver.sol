
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

interface IFlashLoanSimpleReceiver {
    /**
     * @notice Executes an operation after receiving the flash-borrowed asset
     * @dev Ensure that the contract can return the debt + premium, e.g., has
     *      enough funds to repay and has approved the Pool to pull the total amount
     * @param asset The address of the flash-borrowed asset
     * @param amount The amount of the flash-borrowed asset
     * @param premium The fee of the flash-borrowed asset
     * @return True if the execution of the operation succeeds, false otherwise
     */
    function executeOperation(
      address asset,
      uint256 amount,
      uint256 premium,
      address initiator,
      bytes calldata params
    ) external returns (bool);
  
    // function ADDRESSES_PROVIDER() external view returns (IPoolAddressesProvider);
  
    // function POOL() external view returns (IPool);
  }