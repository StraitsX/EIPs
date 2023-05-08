// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/**
*    @dev The ERC-165 identifier for this interface is 0x0e89341c.
*/
interface ERC1155Metadata_URI {
    /**
        @notice A distinct Uniform Resource Identifier (URI) for a given token.
        @dev URIs are defined in RFC 3986.
        The URI MUST point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".        
        @return URI string
    */
    function uri(uint256 _id) external view returns (string memory);
}

/// @title ERC-173 Contract Ownership Standard
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
interface IERC173 {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Get the address of the owner
    /// @return owner_ The address of the owner.
    function owner() external view returns (address owner_);

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}

/// The EIP-165 identifier of this interface is 0xf4cedd5a
interface IERC5679Ext1155 {
   function safeMint(address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;
   function safeMintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
   function burn(address _from, uint256 _id, uint256 _amount, bytes[] calldata _data) external;
   function burnBatch(address _from, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata _data) external;
}

abstract contract PBMRC1 is IPBMRC1, ERC1155Metadata_URI {
    // Implementation on PBM token mapping to ERC1155 goes here
}

/// @notice Smart contracts MUST implement the ERC-165 `supportsInterface` function and signify support for the `PBMRC1_TokenReceiver` interface to accept callbacks.
/// It is optional for a receiving smart contract to implement the `PBMRC1_TokenReceiver` interface
/// @dev WARNING: Reentrancy guard procedure, Non delegate call, or the check-effects-interaction pattern must be adhere to when calling an external smart contract.
/// The interface functions MUST only be called at the end of the `unwrap` function.
interface PBMRC1_TokenReceiver {
    /**
        @notice Handles the callback from a PBM smart contract upon unwrapping
        @dev An PBM smart contract MUST call this function on the token recipient contract, at the end of a `unwrap` if the
        receiver smart contract supports type(PBMRC1_TokenReceiver).interfaceId
        @param _operator  The address which initiated the transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _id        The ID of the token being unwrapped
        @param _value     The amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onPBMRC1Unwrap(address,address,uint256,uint256,bytes)"))`
    */
    function onPBMRC1Unwrap(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    /**
        @notice Handles the callback from a PBM smart contract upon unwrapping a batch of tokens
        @dev An PBM smart contract MUST call this function on the token recipient contract, at the end of a `unwrap` if the
        receiver smart contract supports type(PBMRC1_TokenReceiver).interfaceId

        @param _operator  The address which initiated the transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _id        The ID of the token being unwrapped
        @param _value     The amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onPBMRC1BatchUnwrap(address,address,uint256,uint256,bytes)"))`
    */
    function onPBMRC1BatchUnwrap(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);       
}
