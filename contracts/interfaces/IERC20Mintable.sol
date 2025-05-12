// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IERC20Mintable
/// @notice Interface for mintable ERC-20 tokens
interface IERC20Mintable {
    /// @notice Mints tokens to a specified address
    /// @param to The address that will receive the minted tokens
    /// @param amount The number of tokens to mint (in wei)
    function mint(address to, uint256 amount) external;
}