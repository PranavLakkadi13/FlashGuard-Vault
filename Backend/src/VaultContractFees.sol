// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "./Percentage.sol";
import "./IFlashLoanSimpleReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

/// @dev ERC4626 vault with entry/exit fees expressed in https://en.wikipedia.org/wiki/Basis_point[basis point (bp)].
abstract contract ERC4626Fees is ERC4626 {
    using Math for uint256;
    using PercentageMath for uint256;

    uint256 private constant _BASIS_POINT_SCALE = 1e4;
    uint256 public tokenholders;

    // === Overrides ===

    /// @dev Preview taking an entry fee on deposit. See {IERC4626-previewDeposit}.
    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        uint256 fee = _feeOnTotal(assets, _entryFeeBasisPoints());
        return super.previewDeposit(assets - fee);
    }

    /// @dev Preview adding an entry fee on mint. See {IERC4626-previewMint}.
    function previewMint(uint256 shares) public view virtual override returns (uint256) {
        uint256 assets = super.previewMint(shares);
        return assets + _feeOnRaw(assets, _entryFeeBasisPoints());
    }

    /// @dev Preview adding an exit fee on withdraw. See {IERC4626-previewWithdraw}.
    function previewWithdraw(uint256 assets) public view virtual override returns (uint256) {
        uint256 fee = _feeOnRaw(assets, _exitFeeBasisPoints());
        return super.previewWithdraw(assets + fee);
    }

    /// @dev Preview taking an exit fee on redeem. See {IERC4626-previewRedeem}.
    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        uint256 assets = super.previewRedeem(shares);
        return assets - _feeOnTotal(assets, _exitFeeBasisPoints());
    }

    /// @dev Send entry fee to {_entryFeeRecipient}. See {IERC4626-_deposit}.
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual override {
        uint256 fee = _feeOnTotal(assets, _entryFeeBasisPoints());
        address recipient = _entryFeeRecipient();

        super._deposit(caller, receiver, assets, shares);

        if (fee > 0 && recipient != address(this)) {
            SafeERC20.safeTransfer(IERC20(asset()), recipient, fee);
        }

        unchecked {
            tokenholders++;
        }
    }

    /// @dev Send exit fee to {_exitFeeRecipient}. See {IERC4626-_deposit}.
    function _withdraw(address caller, address receiver, address owner, uint256 assets, uint256 shares)
        internal
        virtual
        override
    {
        uint256 fee = _feeOnRaw(assets, _exitFeeBasisPoints());
        address recipient = _exitFeeRecipient();

        uint256 feeAsset = assets.percentMul(1e1);
        uint256 updatedAssests = assets + feeAsset;
        super._withdraw(caller, receiver, owner, updatedAssests, shares);

        if (fee > 0 && recipient != address(this)) {
            SafeERC20.safeTransfer(IERC20(asset()), recipient, fee);
        }
        unchecked {
            tokenholders--;
        }
    }

    // === Fee configuration ===

    function _entryFeeBasisPoints() internal view virtual returns (uint256) {
        return 0; // replace with e.g. 100 for 1%
    }

    function _exitFeeBasisPoints() internal view virtual returns (uint256) {
        return 0; // replace with e.g. 100 for 1%
    }

    function _entryFeeRecipient() internal view virtual returns (address) {
        return address(0); // replace with e.g. a treasury address
    }

    function _exitFeeRecipient() internal view virtual returns (address) {
        return address(0); // replace with e.g. a treasury address
    }

    // === Fee operations ===

    /// @dev Calculates the fees that should be added to an amount `assets` that does not already include fees.
    /// Used in {IERC4626-mint} and {IERC4626-withdraw} operations.
    function _feeOnRaw(uint256 assets, uint256 feeBasisPoints) private pure returns (uint256) {
        return assets.mulDiv(feeBasisPoints, _BASIS_POINT_SCALE, Math.Rounding.Up);
    }

    /// @dev Calculates the fee part of an amount `assets` that already includes fees.
    /// Used in {IERC4626-deposit} and {IERC4626-redeem} operations.
    function _feeOnTotal(uint256 assets, uint256 feeBasisPoints) private pure returns (uint256) {
        return assets.mulDiv(feeBasisPoints, feeBasisPoints + _BASIS_POINT_SCALE, Math.Rounding.Up);
    }
}

contract VaultWithFee is ERC4626Fees {
    using PercentageMath for uint256;

    address public owner;
    uint256 public entryFeeBasisPoints;
    address public immutable factory;

    constructor(IERC20Metadata _asset, uint256 _basisPoints, address _treasury, address _factory)
        ERC4626(_asset)
        ERC20("Vault Token", "VLT")
    {
        owner = _treasury;
        entryFeeBasisPoints = _basisPoints;
        factory = _factory;
    }

    modifier AfterFlashLoan(address receiver, uint256 amount, uint256 fee) {
        _;
        // uint256 x = amount.percentMul(fee);
        // IERC20(asset()).transferFrom(receiver, address(this), amount + x);
        // if (IERC20(asset()).balanceOf())
    }

    function FlashLoan(address receiver, uint256 amount, uint256 fee) public AfterFlashLoan(receiver, amount, fee) {
        if (amount > IERC20(asset()).balanceOf(address(this))) {
            revert();
        }
        uint256 x = IERC20(asset()).balanceOf(address(this));
        IERC20(asset()).transfer(receiver, amount);

        IFlashLoanSimpleReceiver(receiver).executeOperation(asset(), amount, fee, address(this));

        uint256 y = amount.percentMul(fee);
        IERC20(asset()).transferFrom(receiver, address(this), amount + y);
        if (IERC20(asset()).balanceOf(address(this)) <= x) {
            revert();
        }
    }

    // === Fee configuration ===
    function _entryFeeBasisPoints() internal view virtual override returns (uint256) {
        return 0; // replace with e.g. 100 for 1%
    }

    function _exitFeeRecipient() internal view virtual override returns (address) {
        return owner; // replace with e.g. a treasury address
    }

    function _entryFeeRecipient() internal view virtual override returns (address) {
        return owner; // replace with e.g. a treasury address
    }

    function _exitFeeBasisPoints() internal view virtual override returns (uint256) {
        return 0; // replace with e.g. 100 for 1%
    }
}
