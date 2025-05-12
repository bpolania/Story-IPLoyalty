// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { IRegistrationWorkflows } from "@story-protocol/periphery/contracts/interfaces/workflows/IRegistrationWorkflows.sol";
import { WorkflowStructs } from "@story-protocol/periphery/contracts/lib/WorkflowStructs.sol";
import { ISPGNFT } from "@story-protocol/periphery/contracts/interfaces/ISPGNFT.sol";
import { IERC20Mintable } from "./interfaces/IERC20Mintable.sol";

contract IPLoyalty {
    IRegistrationWorkflows public registrationWorkflows;
    address public spgNftContract;

    mapping(uint256 => address) public loyaltyTokenForUser;

    event UserRegistered(
        string username,
        uint256 tokenId,
        address nftOwner,
        address loyaltyToken,
        address ipId
    );

    constructor(address registrationWorkflowAddress, ISPGNFT.InitParams memory initParams) {
        registrationWorkflows = IRegistrationWorkflows(registrationWorkflowAddress);

        // Deploy a new SPGNFT collection
        spgNftContract = registrationWorkflows.createCollection(initParams);
        emit CollectionCreated(spgNftContract);
    }

    function registerUser(
        string memory username,
        WorkflowStructs.IPMetadata memory metadata
    ) external {
        // Mint NFT & register IP via Story Protocol
        (address ipId, uint256 tokenId) = registrationWorkflows.mintAndRegisterIp(
            spgNftContract,
            msg.sender,
            metadata,
            false
        );

        // Deploy loyalty ERC-20 token for the username
        string memory tokenName = string(abi.encodePacked(username, " Token"));
        string memory tokenSymbol = string(abi.encodePacked("LOY", toUpper(username)));

        IERC20Mintable token = new IERC20Mintable(
            tokenName,
            tokenSymbol,
            1_000_000 ether,
            msg.sender
        );

        loyaltyTokenForUser[tokenId] = address(token);

        emit UserRegistered(username, tokenId, msg.sender, address(token), ipId);
    }

    function toUpper(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        for (uint i = 0; i < bStr.length; i++) {
            if (bStr[i] >= 0x61 && bStr[i] <= 0x7A) {
                bStr[i] = bytes1(uint8(bStr[i]) - 32);
            }
        }
        return string(bStr);
    }

    event CollectionCreated(address indexed spgNftContract);
}