// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

abstract contract IPBMRC1_TokenManager {
    /// @dev Mapping of each ERC-1155 tokenId to its corresponding PBM Token details.
    mapping (uint256 => PBMToken) internal tokenTypes ; 

    /// @dev Structure representing all the details corresponding to a PBM tokenId.
    struct PBMToken {
        //Compulsory state variables (name, faceValue, expiry, creator, balanceSupply and uri) MUST be included for all PBM token implementing this interface.
        // Name of the token.
        string name;
        // Value of the underlying wrapped ERC20-compatible Spot Token.
        uint256 faceValue;
        // Token will be rendered useless after this time (expressed in Unix Epoch time).
        uint256 expiry;
        // Address of the creator of this PBM type on this smart contract.
        address creator;
        // Remaining balance of the token.
        uint256 balanceSupply;
        // Metadata URI for ERC1155 display purposes.
        string uri;

        // Add other OPTIONAL state variables below...

    }

    /// @notice Creates a new PBM Token type with the provided data.
    /// @dev Example response of token URI (reference: https://docs.opensea.io/docs/metadata-standards):
    /// {
    ///     "name": "StraitsX-12",
    ///     "description": "$12 SGD test voucher",
    ///     "image": "https://gateway.pinata.cloud/ipfs/QmQ1x7NHakFYin9bHwN7zy4NdSYS84w6C33hzxpZwCAFPu",
    ///     "attributes": [
    ///         {
    ///             "trait_type": "Value",
    ///             "value": "12"
    ///         }
    ///     ]
    /// }
    function createPBMTokenType(
        string memory _name,
        uint256 _faceValue,
        uint256 _tokenExpiry,
        address _creator,
        string memory _tokenURI
    ) external;


    /// @notice Retrieves the details of a PBM Token type given its tokenId.
    /// @dev This function fetches the PBMToken struct associated with the tokenId and returns it.
    /// @param _tokenId The identifier of the PBM token type.
    /// @return A PBMToken struct containing all the details of the specified PBM token type.
    function getTokenDetails(uint256 _tokenId) external view returns(PBMToken memory); 
}

