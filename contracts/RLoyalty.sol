// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { RoyaltyModule } from "@story-protocol/core/contracts/modules/royalty/RoyaltyModule.sol";
import { IERC20Mintable } from "./interfaces/IERC20Mintable.sol";
import { IPLoyalty } from "./IPLoyalty.sol";

contract RLoyalty is RoyaltyModule {
    IPLoyalty public immutable loyaltyRegistry;

    constructor(address _iplAddress) {
        loyaltyRegistry = IPLoyalty(_iplAddress);
    }

    /// @notice Pays royalties and rewards the payer with ERC-20 loyalty tokens (multiplied)
    /// @param receiverIpId IP that receives the royalty
    /// @param token ERC20 used for royalty payment
    /// @param amount Amount paid
    /// @param rewardToken Loyalty token to mint
    /// @param multiplier Multiplier for loyalty reward
    function rewardRoyalty(
        address receiverIpId,
        address token,
        uint256 amount,
        address rewardToken,
        uint256 multiplier
    ) external {
        // Step 1: Pay royalties
        uint256 amountAfterFee = _payRoyalty(receiverIpId, msg.sender, token, amount);

        // Step 2: Validate ownership
        address expectedOwner = loyaltyRegistry.ownerOfLoyaltyToken(rewardToken);
        require(expectedOwner == msg.sender, "Not the owner of the loyalty token");

        // Step 3: Mint rewards
        uint256 rewardAmount = amountAfterFee * multiplier;
        IERC20Mintable(rewardToken).mint(msg.sender, rewardAmount);

        emit RoyaltyRewarded(receiverIpId, msg.sender, token, amountAfterFee, rewardAmount);
    }

    event RoyaltyRewarded(
        address indexed ipId,
        address indexed recipient,
        address paymentToken,
        uint256 royaltyPaid,
        uint256 rewardAmount
    );
}