// SPDX-License-Identifier: GPL-3.0 
pragma solidity 0.8.17;

import "@zoralabs/zora-1155-contracts/src/interfaces/IMinter1155.sol";

interface IZoraCreator1155 {
    // original interface is missing the setupNewTokenWithCreateReferral
    function setupNewTokenWithCreateReferral(string memory tokenURI, uint256 maxSupply, address ) external returns (uint256 tokenId);
    function callSale(uint256 tokenId, IMinter1155 salesConfig, bytes memory data) external;
}

contract CommunityEditionManager {
    IZoraCreator1155 iface;

    struct SalesConfig {
        /// @notice Unix timestamp for the sale start
        uint64 saleStart;
        /// @notice Unix timestamp for the sale end
        uint64 saleEnd;
        /// @notice Max tokens that can be minted for an address, 0 if unlimited
        uint64 maxTokensPerAddress;
        /// @notice Price per token in eth wei
        uint96 pricePerToken;
        /// @notice Funds recipient (0 if no different funds recipient than the contract global)
        address fundsRecipient;
    }

    function createToken(
        address _erc1155Impl,
        string memory _tokenUri,
        uint256 _maxSupply,
        IMinter1155 _minter,
        uint64 _saleStart,
        uint64 _saleEnd,
        uint64 _maxPerWallet,
        uint96 _tokenPrice,
        address _rewardsRecipient
    ) public returns (uint256 tokenId) {
        iface = IZoraCreator1155(_erc1155Impl);
        tokenId = iface.setupNewTokenWithCreateReferral(_tokenUri, _maxSupply, _rewardsRecipient);

        bytes memory data = abi.encodeWithSignature(
            "setSale(uint256,(uint64,uint64,uint64,uint96,address))",
            tokenId, SalesConfig(
                _saleStart,
                _saleEnd,
                _maxPerWallet,
                _tokenPrice,
                _rewardsRecipient
            )
        );

        iface.callSale(tokenId, _minter, data);
    }
}
