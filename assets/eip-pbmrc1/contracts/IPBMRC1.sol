// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

// TBD: go through each function params and adopt _param name standard?
// TBD: check the parameters of each functions. are they necessary? does it need to be an array?
/// LIST OF EVENTS TO BE EMITTED
// TBD: check the parameters of the events 
// TBD: consider these events to be added into safeMint functions if they are going to wrap an underlying ERC20tokens
// TBD: consider other events to be EMITTED 
// TBD: event logs emitted by the smart contract will provide enough data to create an accurate record of all current token balances.
// A database or explorer may listen to events and be able to provide indexed and categorized searches

/// @title PBM Specification interface 
/// @notice The PBM (purpose bound money) allows us to add logical requirements on the use of ERC-20 tokens. 
/// The PBM acts as wrapper around the ERC-20 tokens and implements the necessary logic. 
/// @dev PBM creator must assign an overall owner to the smart contract. If fine grain access controls are required, EIP-5982 can be used on top of ERC173
interface IPBMRC1 is IERC173, IERC5679Ext1155 {
    
    /// @notice Initialise the contract by specifying an underlying ERC20-compatible token address,
    /// contract expiry, and the PBM address list.
    /// @param _spotToken   The address of the underlying ERC20 token.
    /// @param _expiry      The contract-wide expiry timestamp (in Unix epoch time).
    /// @param _purposeBoundAddressList This should point to a smart contract that manages the condition by which a PBM is allowed to move to or to be unwrapped.
    function initialise(address _spotToken, uint256 _expiry, address _purposeBoundAddressList) external; 

    /// @notice Returns the Uniform Resource Identifier (URI) metadata information for the PBM with the corresponding tokenId
    /// @dev URIs are defined in RFC 3986. 
    /// The URI MUST point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
    /// Developer may choose to adhere to the ERC1155Metadata_URI extension interface if necessary
    /// @param _tokenId     The id for the PBM in query
    /// @return _uriString  Returns the metadata URI string for the PBM
    function uri(uint256 _tokenId) external  view returns (string memory);
    
    /**
        @notice Creates a PBM copy ( ERC1155 NFT ) of an existing PBM token type.
        @dev See {IERC5679Ext1155} on further implementation notes
        @param _receiver    The wallet address to which the created PBMs need to be transferred to
        @param _tokenId     The identifier of the PBM token type to be copied.
        @param _amount      The number of the PBMs that are to be created
        @param _data        Additional data with no specified format, based on eip-5750
            
        IMPT: Before minting, the caller should approve the contract address to spend ERC-20 tokens on behalf of the caller.
            This can be done by calling the `approve` or `increaseMinterAllowance` functions of the ERC-20 contract and specifying `_spender` to be the PBM contract address. 
            Ref : https://eips.ethereum.org/EIPS/eip-20

        WARNING: Any contracts that externally call these safeMint() and safeMintBatch() functions should implement some sort of reentrancy guard procedure 
        (such as OpenZeppelin's ReentrancyGuard) or a Checks-effects-interactions pattern.

        As per ERC-5679 standard: When the token is being minted, the transfer events MUST be emitted as if the token in the `_amount` for EIP-1155 
        and `_tokenId` being _id for EIP-1155 were transferred from address 0x0 to the recipient address identified by receiver. 
        The total supply MUST increase accordingly.

        Requirements:
        - contract must not be paused
        - tokens must not be expired
        - `_tokenId` should be a valid id that has already been created
        - caller should have the necessary amount of the ERC-20 tokens required to mint
        - caller should have approved the PBM contract to spend the ERC-20 tokens
        - receiver should not be blacklisted
     */
    function safeMint(address _receiver, uint256 _tokenId, uint256 _amount, bytes calldata _data) external;

    /**
        @notice Creates multiple PBM copies ( ERC1155 NFT ) of an existing PBM token type.
        @dev See {IERC5679Ext1155}.
        @param _tokenIds    The identifier of the PBM token types
        @param _receiver    The wallet address to which the created PBMs need to be transferred to
        @param _amounts     The amount of the PBMs that are to be created for each tokenId in _tokenIds
        @param _data        Additional data with no specified format, based on eip-5750

        IMPT: Before minting, the caller should approve the contract address to spend ERC-20 tokens on behalf of the caller.
            This can be done by calling the `approve` or `increaseMinterAllowance` functions of the ERC-20 contract and specifying `_spender` to be the PBM contract address. 
            Ref : https://eips.ethereum.org/EIPS/eip-20

        WARNING: Any contracts that externally call these safeMint() and safeMintBatch() functions should implement some sort of reentrancy guard procedure 
        (such as OpenZeppelin's ReentrancyGuard) or a Checks-effects-interactions pattern.

        As per ERC-5679 standard: When the token is being minted, the transfer events MUST be emitted as if the token in the `_amounts` for EIP-1155 
        and `_tokenIds` being _id for EIP-1155 were transferred from address 0x0 to the recipient address identified by receiver. 
        The total supply MUST increase accordingly.

        Requirements:
        - contract must not be paused
        - tokens must not be expired
        - `_tokenIds` should all be valid ids that have already been created
        - `_tokenIds` and `_amounts` list need to have the same number of values
        - caller should have the necessary amount of the ERC-20 tokens required to mint
        - caller should have approved the PBM contract to spend the ERC-20 tokens
        - receiver should not be blacklisted
     */
    function safeMintBatch(address _receiver, uint256[] calldata _tokenIds, uint256[] calldata _amounts, bytes calldata _data) external;

    /**
        @notice Burns a PBM token. Upon burning of the tokens, the underlying unwrapped token (if any) should be handled.
        @dev Destroys `amount` tokens of token type `tokenId` from `from`
        @dev See {IERC5679Ext1155}

        @param _from        The wallet address the PBMs to be burned needs to be transferred from
        @param _tokenId     The identifier of the PBM token type
        @param _amount      The amount of the PBMs that are to be burned
        @param _data        Additional data with no specified format, based on eip-5750

        Must Emits {TransferSingle} event.
        Must Emits {TokenUnwrapPBMBurn} event if the underlying wrapped token is moved out of the PBM smart contract.

        Requirements:
        - `_from` cannot be the zero address.
        - `_from` must have at least `_amount` tokens of token type `_tokenId`.

     */
    function burn(address _from, uint256 _tokenId, uint256 _amount, bytes calldata _data) external;

    /**
        @notice Burns multiple PBM token. Upon burning of the tokens, the underlying wrapped token (if any) should be handled.
        @dev Destroys `amount` tokens of token type `tokenId` from `from`
        @dev See {IERC5679Ext1155}

        @param _from        The wallet address the PBMs to be burned need to be transferred from
        @param _tokenIds    The identifier of the PBM token types
        @param _amounts     The amount of the PBMs that are to be burned for each tokenId in _tokenIds
        @param _data        Additional data with no specified format, based on eip-5750

        Must Emits {TransferSingle} event.
        Must Emits {TokenUnwrapPBMBurn} event if the underlying wrapped token is moved out of the PBM smart contract.

        Requirements:
        - `_from` cannot be the zero address.
        - `_from` must have at least amount specified in `_amounts` of the corresponding token type tokenId in `_tokenIds` array.
     */
    function burnBatch(address _from, uint256[] calldata _tokenIds, uint256[] calldata _amounts, bytes calldata _data) external;

    /// @notice Transfers the PBM(NFT) from one wallet to another. 
    /// @dev This function extends the ERC-1155 standard in order to allow the PBM token to be freely transferred between wallet addresses due to 
    /// widespread support accross wallet providers. Specific conditions and restrictions on whether a PBM can be moved across addresses can be incorporated in this function.
    /// Unwrap logic MAY also be placed within this function to be called.

    /// @param _from    The account from which the PBM ( NFT ) is moving from 
    /// @param _to      The account which is receiving the PBM ( NFT )
    /// @param _id      The identifier of the PBM token type
    /// @param _amount  The number of (quantity) the PBM type that are to be transferred of the PBM type
    /// @param _data    To record any data associated with the transaction, can be left blank if none
    function safeTransferFrom( address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data) external; 

    /// @notice Transfers the PBM(NFT)(s) from one wallet to another. 
    /// @dev This function extends the ERC-1155 standard in order to allow the PBM token to be freely transferred between wallet addresses due to 
    /// widespread support accross wallet providers.  Specific conditions and restrictions on whether a pbm can be moved across addresses can be incorporated in this function.
    /// Unwrap logic MAY also be placed within this function to be called.
    /// If the receving wallet is a whitelisted merchant wallet address, the PBM(NFT)(s) will be burnt and the underlying ERC-20 tokens will be transferred to the merchant wallet instead.
    /// @param _from    The account from which the PBM ( NFT )(s) is moving from 
    /// @param _to      The account which is receiving the PBM ( NFT )(s)
    /// @param _ids     The identifiers of the different PBM token type
    /// @param _amounts The number of ( quantity ) the different PBM types that are to be created
    /// @param _data    To record any data associated with the transaction, can be left blank if none. 
    function safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids,uint256[] memory _amounts, bytes memory _data) external; 

    /// @notice Unwraps the underlying ERC-20 compatible tokens to an intended end point (ie: merchant) upon fulfilling the required PBM conditions.
    /// @dev Add implementation specific logic for the conditions under which a PBM processes and transfers the underlying tokens here.
    /// e.g. If the receving wallet is a whitelisted merchant wallet address, the PBM(NFT) will be burnt and the underlying ERC-20 tokens 
    /// will unwrapped to be transferred to the merchant wallet instead.
    /// @param _from    The account currently holding the PBM
    /// @param _to      The account receiving the PBM (NFT)
    /// @param _tokenId The identifier of the PBM token type
    /// @param _amount  The quantity of the PBM type involved in this transaction
    /// @param _data    Additional data without a specified format, based on EIP-5750
    function unwrap(address _from, address _to, uint256 _tokenId, uint256 _amount, bytes memory _data) internal; 

    /// @notice Allows the creator of a PBM token type to retrieve all locked-up underlying ERC-20 tokens within that PBM.
    /// @dev Ensure that only the creator of the PBM token type or the contract owner can call this function. 
    /// Validate the token state and existence, handle PBM token burning if necessary, safely transfer the remaining ERC-20 tokens to the originator, 
    /// must emit {PBMrevokeWithdraw} upon a successful revoke.
    /// @param _tokenId The identifier of the PBM token type
    /// Requirements:
    /// - `tokenId` should be a valid identifier for an existing PBM token type.
    /// - The caller must be either the creator of the token type or the smart contract owner.
    function revokePBM(uint256 _tokenId) external;

    /// @notice Emitted when a new Purpose-Bound Token (PBM) type is created within the contract.
    /// @param _tokenId     The unique identifier for the newly created PBM token type.
    /// @param _tokenName   A human-readable string representing the name of the newly created PBM token type.
    /// @param _amount      The initial supply of the newly created PBM token type.
    /// @param _expiry      The timestamp at which the newly created PBM token type will expire.
    /// @param _creator     The address of the account that created the new PBM token type.
    event NewPBMTypeCreated(uint256 _tokenId, string _tokenName, uint256 _amount, uint256 _expiry, address _creator);

    /// @notice Emitted when a PBM type creator withdraws the underlying ERC-20 tokens from all the remaining expired PBMs
    /// @param _beneficiary     The address ( PBM type creator ) which receives the ERC20 Token
    /// @param _PBMTokenId      The identifiers of the different PBM token type
    /// @param _ERC20Token      The address of the underlying ERC-20 token 
    /// @param _ERC20TokenValue The number of underlying ERC-20 tokens transferred 
    event PBMrevokeWithdraw(address _beneficiary, uint256 _PBMTokenId, address _ERC20Token, uint256 _ERC20TokenValue);

    /// @notice Emitted when the underlying tokens are unwrapped and transferred to a specific purpose-bound address.
    /// This event signifies the end of the PBM lifecycle, as all necessary conditions have been met to release the underlying tokens to the recipient.
    /// @param _from            The address from which the PBM tokens are being unwrapped.
    /// @param _to              The purpose-bound address receiving the unwrapped underlying tokens.
    /// @param _tokenIds        An array containing the identifiers of the unwrapped PBM token types.
    /// @param _amounts         An array containing the quantities of the corresponding unwrapped PBM tokens.
    /// @param _ERC20Token      The address of the underlying ERC-20 token.
    /// @param _ERC20TokenValue The amount of unwrapped underlying ERC-20 tokens transferred.
    event TokenUnwrapForTarget(address _from, address _to, uint256[] _tokenIds, uint256[] _amounts, address _ERC20Token, uint256 _ERC20TokenValue);

    /// @notice Emitted when PBM tokens are burned, resulting in the unwrapping of the underlying tokens for the designated recipient.
    /// This event is required if there is an unwrapping of the underlying tokens during the PBM (NFT) burning process.
    /// @param _from            The address from which the PBM tokens are being burned.
    /// @param _to              The address receiving the unwrapped underlying tokens.
    /// @param _tokenIds        An array containing the identifiers of the burned PBM token types.
    /// @param _amounts         An array containing the quantities of the corresponding burned PBM tokens.
    /// @param _ERC20Token      The address of the underlying ERC-20 token.
    /// @param _ERC20TokenValue The amount of unwrapped underlying ERC-20 tokens transferred.
    event TokenUnwrapForPBMBurn(address _from, address _to, uint256[] _tokenIds, uint256[] _amounts, address _ERC20Token, uint256 _ERC20TokenValue);

    /// Indicates the wrapping of an token into the PBM smart contract. 
    /// @notice Emitted when underlying tokens are wrapped within the PBM smart contract.
    /// This event signifies the beginning of the PBM lifecycle, as tokens are now managed by the conditions within the PBM contract.
    /// @param _from            The address initiating the token wrapping process, and 
    /// @param _tokenIds        An array containing the identifiers of the token types being wrapped.
    /// @param _amounts         An array containing the quantities of the corresponding wrapped tokens.
    /// @param _ERC20Token      The address of the underlying ERC-20 token.
    /// @param _ERC20TokenValue The amount of wrapped underlying ERC-20 tokens transferred.
    event TokenWrap(address _from, uint256[] _tokenIds, uint256[] _amounts,address _ERC20Token, uint256 _ERC20TokenValue); 
}


