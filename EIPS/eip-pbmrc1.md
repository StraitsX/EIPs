---
eip: TBD
title: Purpose bound money
description: An interface extending EIP-1155 for <placeholder>, supporting use case such as <placeholder>
authors: Victor Liew (@Alcedo), Wong Tse Jian (@wongtsejian)
discussions-to: https://ethereum-magicians.org (Create a discourse here for early feedback)
status:  DRAFT
type: Standards Track
category: ERC
created: 2023-04-01
requires: 165, 173, 1155
---

<!-- Notes: replace PRBMRC with EIP upon creating a PR to EIP Main repo -->
## Abstract

This PBMRC outlines a smart contract interface that builds upon the [ERC-1155](./eip-1155.md) standard to introduce the concept of a purpose bound money (PBM) defined in the [Project Orchid Whitepaper](../assets/eip-pbmrc1/MAS-Project-Orchid.pdf).

It builds upon the [ERC-1155](./eip-1155.md) standard, by leveraging pre-existing, widespread support that wallet providers have implemented, to display the PBM and trigger various transfer logic.

## Motivation

The establishment of this protocol seeks to forestalls technology fragmentation and consequently a lack of interoperability. By making the PBM specification open, it gives new participants easy and free access to the pre-existing market standards, enabling interoperability across different platforms, wallets, payment systems and rails. This would lower cost of entry for new participants, foster a vibrant payment landscape and prevent the development of walled gardens and monopolies, ultimately leading to more efficient, affordable services and better user experiences.

## Definitions

A PBM based architecture has several distinct components:

- **Spot Token** - a ERC-20 or ERC-20 compatible digital currency (e.g. ERC-777, ERC-1363) serving as the collateral backing the PBM Token.
  - Digital currency referred to in this PBMRC paper **SHOULD** possess the following properties:
    - a good store of value;
    - a suitable unit of account; and
    - a medium of exchange;
- **Spot Token Issuer** - is a regulated financial institution providing the underlying digital currency backing the PBM Token. Spot Token Issuer mints a compatible digital currency when it receives fiat currencies from a PBM Creator and burns digital currency when a PBM Token recipient wishes to exchange unwrapped PBM Tokens for fiat currencies.
- **PBM Wrapper** - a smart contract, which wraps the Spot Token, by specifying condition(s) that has/have to be met (referred to as PBM business logic in subsequent section of this paper). The smart contract verifies that condition(s) has/have been met before unwrapping the underlying Spot Token;
- **PBM Token** - the Spot Token and its PBM wrapper are collectively referred to as a PBM Token. PBM Tokens are represented as a [ERC-1155](./eip-1155.md) token.
  - PBM Tokens are bearer instruments, with self-contained programming logic, and can be transferred between two parties without involving intermediaries. It combines the concept of:
    - programmable payment - automatic execution of payments once a pre-defined set of conditions are met; and
    - programmable money - the possibility of embedding rules within the medium of exchange itself that defines or constraints its usage.
- **PBM Creator** defines the conditions of the PBM Wrapper to create PBM Tokens. A PBM Creator is able to issue any amount of PBM Tokens, provided that the PBM Creator deposits equivalent amounts of fiat currencies with the Spot Token Issuer.
- **PBM Infrastructure** - consisting of a ledger-based infrastructure. While a PBM can be either distributed ledger technology (DLT) based or non-DLT based, the scope of this PBMRC paper is limited to a DLT-based infrastructure build upon the Ethereum blockchain;
- **PBM Wallet** - cryptographic wallets which holds users' private keys, granting them access to PBMs.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [BCP 14](https://www.rfc-editor.org/info/bcp14) [ [RFC2119](https://www.rfc-editor.org/rfc/rfc2119.txt) ] [ [RFC8174](https://www.rfc-editor.org/rfc/rfc8174.txt) ] when, and only when, they appear in all capitals, as shown here.

### Overview

- Whether a PBM Token **SHOULD** have an expiry time will be decided by the PBM Creator, the spec itself should not enforce an expiry time.
  - To align with our goals of making PBM Token a suitable construct for all kinds of business logic that could occur in the real world.

  - Should an expiry time not be needed, the expiry time can be set to infinity.

- PBM **SHALL** adhere to the definition of “wrap” or “wrapping” to mean bounding a token in accordance with PBM business logic during its lifecycle stage.

- PBM **SHALL** adhere to the definition of “unwrap” or “unwrapping” to mean the release of a token in accordance with the PBM business logic during its lifecycle stage.

- A valid PBM Token **MUST** consists of an underlying Spot Token and the PBM Wrapper.
  - The wrapping of the Spot Token can be done either upon the creation of the PBM Token or at a later date prior to its issuance.
  
  - A Spot Token can implement any widely accepted ERC-20 compatible ERC e.g. ERC-20, ERC-777, ERC-1363.

- PBM Wrapper **MUST** provide a mechanism for all transacting parties to verify that all necessary condition(s) have been met before allowing the PBM Token to be unwrapped.

- There **MUST** be an owner (i.e. PBM Creator) responsible for the creation and maintenance of the PBM.
  
- This paper defines a base specification of what a PBM should entail. Extensions to this base specification can be implemented as separate specifications.

### Fungibility

A PBM Wrapper **SHOULD** be able to wrap multiple types of compatible Spot Tokens. Spot Tokens wrapped by the same PBM wrapper may or may not be fungible to one another. The standard does NOT mandate how an implementation must do this.

### A Note on Implementing Interfaces

In order to allow the implementors of this PBM standard to have maximum flexibility in the way they structure the PBM business logic, a PBM can implement this interface in two ways:

- directly by declaring that (`contract ContractName is InterfaceName`); or
- indirectly by adding all functions from this interface into the contract. The indirect method allows the contract to implement additional interfaces.

### PBM token details

A state variable consisting of all additional details required to facilitate the business logic for a particular PBM type MUST be defined. The compulsory fields are listed in the `struct PBMToken` (below), additional, optional state variables may be defined by later proposals.

An external function may be exposed to create new PBM Token as well at a later date.

Example of token details:

```solidity

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
        string memory name,
        uint256 faceValue,
        uint256 tokenExpiry,
        address creator,
        string memory tokenURI
    ) external;


    /// @notice Retrieves the details of a PBM Token type given its tokenId.
    /// @dev This function fetches the PBMToken struct associated with the tokenId and returns it.
    /// @param tokenId The identifier of the PBM token type.
    /// @return A PBMToken struct containing all the details of the specified PBM token type.
    function getTokenDetails(uint256 tokenId) external view returns(PBMToken memory); 
```

### PBM Address List

A list of targeted addresses for PBM unwrapping must be specified in an address list.

```solidity

pragma solidity ^0.8.0;

/// @title PBM Address list Interface. Functions and events relating to whitelisting of merchant stores 
/// and blacklisting of wallet addresses.
/// @notice This interface defines a scheme to manage whitelisted merchant addresses and blacklisted  
/// wallet addresses for the PBMs. A merchant in general is anyone who is providing goods or services 
/// and is hence deemed to be able to unwrap a PBM.
/// Implementers will define the appropriate logic to whitelist or blacklist specific merchant addresses.

interface IPBMAddressList {

    /// @notice Adds wallet addresses to the blacklist, preventing them from receiving PBM tokens.
    /// @param _addresses An array of wallet addresses to be blacklisted.
    /// @param _metadata Optional comments or notes about the blacklisted addresses.
    function blacklistAddresses(address[] memory _addresses, string memory _metadata) external; 

    /// @notice Removes wallet addresses from the blacklist, allowing them to receive PBM tokens.
    /// @param _addresses An array of wallet addresses to be removed from the blacklist.
    /// @param _metadata Optional comments or notes about the removed addresses.
    function unBlacklistAddresses(address[] memory _addresses, string memory _metadata) external; 

    /// @notice Checks if the address is one of the blacklisted addresses
    /// @param _address The address to query
    /// @return _bool True if address is blacklisted, else false
    function isBlacklisted(address _address) external returns (bool) ; 

    /// @notice Registers merchant wallet addresses to differentiate between users and merchants.
    /// @dev The 'unwrapTo' function is called when invoking the PBM 'safeTransferFrom' function for valid merchant addresses.
    /// @param _addresses An array of merchant wallet addresses to be added.
    /// @param _metadata Optional comments or notes about the added addresses.
    function addMerchantAddresses(address[] memory _addresses, string memory _metadata) external; 

    /// @notice Unregisters wallet addresses from the merchant list.
    /// @dev Removes the specified wallet addresses from the list of recognized merchants.
    /// @param _addresses An array of merchant wallet addresses to be removed.
    /// @param _metadata Optional comments or notes about the removed addresses.
    function removeMerchantAddresses(address[] memory _addresses, string memory _metadata) external; 

    /// @notice Checks if the address is one of the whitelisted merchant
    /// @param _address The address to query
    /// @return _bool True if the address is a merchant that is NOT blacklisted, otherwise false.
    function isMerchant(address _address) external returns (bool) ; 
    
    /// @notice Event emitted when the Merchant List is edited
    /// @param action Tags "add" or "remove" for action type
    /// @param addresses An array of merchant wallet addresses that was whitelisted
    /// @param metadata Optional comments or notes about the added or removed addresses.
    event MerchantList(string _action, address[] _addresses, string _metadata);
    
    /// @notice Event emitted when the Blacklist is edited
    /// @param action Tags "add" or "remove" for action type
    /// @param addresses An array of wallet addresses that was blacklisted
    /// @param metadata Optional comments or notes about the added or removed addresses.
    event Blacklist(string _action, address[] _addresses, string _metadata);
}

```

### PBMRC1 - Base Interface

This interface contains the essential functions required to implement a pre-loaded PBM.

```solidity
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
```

## Extensions

### PBMRC1 - Token Receiver

Smart contracts MUST implement all of the functions in the PBMRC1_TokenReceiver interface to subscribe to PBM unwrap callbacks.

```solidity
pragma solidity ^0.8.0;

/// @notice Smart contracts MUST implement the ERC-165 `supportsInterface` function and signify support for the `PBMRC1_TokenReceiver` interface to accept callbacks.
/// It is optional for a receiving smart contract to implement the `PBMRC1_TokenReceiver` interface
/// @dev WARNING: Reentrancy guard procedure, Non delegate call, or the check-effects-interaction pattern must be adhere to when calling an external smart contract.
/// The interface functions MUST only be called at the end of the `unwrap` function.
interface PBMRC1_TokenReceiver {
    /**
        @notice Handles the callback from a PBM smart contract upon unwrapping
        @dev An PBM smart contract MUST call this function on the token recipient contract, at the end of a `unwrap` if the
        receiver smart contract supports type(PBMRC1_TokenReceiver).interfaceId
        @param _operator  The address which initiated the transfer (either the address which previously owned the token or the address authorised to make transfers on 
                          the owner's behalf) (i.e. msg.sender)
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

        @param _operator  The address which initiated the transfer (either the address which previously owned the token or the address authorised to make transfers on 
                          the owner's behalf) (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _id        The ID of the token being unwrapped
        @param _value     The amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onPBMRC1BatchUnwrap(address,address,uint256,uint256,bytes)"))`
    */
    function onPBMRC1BatchUnwrap(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);       
}

```

### PBMRC2 - Non preloaded PBM Interface

The **Non Preloaded** PBM extension is OPTIONAL for compliant smart contracts. This allows contracts to bind an underlying Spot Token to the PBM at a later date instead of during a minting process.

Compliant contract **MUST** implement the following interface:

<!-- TBD Copy from IPBMRC2.sol -->
```solidity

pragma solidity ^0.8.0;

// TBD: add param docs for load, loadto. Check all params documented.

/**
 *  @dev This interface extends IPBMRC1, adding functions for working with non-preloaded PBMs.
 *  Non-preloaded PBMs are minted as empty containers without any underlying tokens of value,
 *  allowing the loading of the underlying token to happen at a later stage.
 */
interface PBMRC2_NonPreloadedPBM is IPBMRC1 {

  /// @notice This function extends IPBMRC1 to mint PBM tokens as empty containers without underlying tokens of value.
  /// @dev The loading of the underlying token of value can be done by calling the `load` function. The function parameters should be identical to IPBMRC1
  function safeMint(address _receiver, uint256 _tokenId, uint256 _amount, bytes calldata _data) external;

  /// @notice This function extends IPBMRC1 to mint PBM tokens as empty containers without underlying tokens of value.
  /// @dev The loading of the underlying token of value can be done by calling the `load` function. The function parameters should be identical to IPBMRC1
  function safeMintBatch(address _receiver, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;

  /// Given a PBM token id, wrap an amount of ERC20 tokens that is purpose bound by `tokenId` 
  /// function will pull ERC20 tokens from msg.sender 
  /// Approval must be given to the PBM smart contract in order to for the pbm to pull money from msg.sender
  /// underlying data structure must record how much the msg.sender has loaded in for the particular pbm `tokenId`
  /// in this function call, the msg.sender is the user bearing the PBM token
  /// loading conditions can be specify in this function.
  /// @dev allocates underlying token to be used exclusively by the PBM token `tokenId` type
  /// @param _tokenId   The identifier of the PBM token type to load
  /// @param _amount    The amount of ERC20 tokens to be loaded
  function load(uint256 _tokenId, uint256 _amount) external; 

  /// Given a PBM token id, wrap an amount of ERC20 tokens into it.
  /// function will pull ERC20 tokens from msg.sender 
  /// underlying data structure will record how much the msg.sender has loaded into the PBM to be given to a recipient
  /// @dev allocates underlying token to be used exclusively by the PBM token `tokenId` type for `recipient`
  /// @param _tokenId   The identifier of the PBM token type to load
  /// @param _amount    The amount of ERC20 tokens to be loaded for `recipient`
  /// @param _recipient The recipient to receive the loaded ERC20 tokens.
  function loadTo(uint256 _tokenId, uint256 _amount, address _recipient) external; 
  
  /// @notice Retrieves the balance of the underlying ERC-20 token associated with a specific PBM token type and user address.
  /// This function provides a way to check the amount of the underlying token that a user has loaded into a particular PBM token.
  /// @param _tokenId   The identifier of the PBM token type for which the underlying token balance is being queried.
  /// @param _user      The address of the user whose underlying token balance is being queried.
  /// @return _balance  The balance of the underlying ERC-20 token associated with the specified PBM token type and u address.
  function underlyingBalanceOf(uint256 _tokenId, address _user) external view returns (uint256);

  /// @notice Unloads the underlying token from the PBM smart contract by extracting the specified amount of the token for the caller.
  /// Emits {TokenUnload} event.
  /// @dev The underlying token will be removed and transferred to the address of the caller (msg.sender).
  /// @param _tokenId   Identifier of the PBM token type to be unloaded.
  /// @param _amount    The quantity of the corresponding tokens to be unloaded.
  function unload(uint256 _tokenId, uint256 _amount) external;

  /// Emitted when an underlying token is loaded into a PBM
  /// @param _caller            The address initiating the token loading process and from which ERC20token is taken.
  /// @param _to                Address by which the token is loaded and assigned to
  /// @param _tokenId           Identifier of the PBM token types being loaded
  /// @param _amount            The quantity of tokens to be loaded
  /// @param _ERC20Token        The address of the underlying ERC-20 token.
  /// @param _ERC20TokenValue   The amount of underlying ERC-20 tokens loaded
  event TokenLoad(address _caller, address _to, uint256 _tokenId, uint256 _amount, address _ERC20Token, uint256 _ERC20TokenValue); 

  /// @notice Emitted when an underlying token is unloaded from a PBM.
  /// This event indicates the process of releasing the underlying token from the PBM smart contract.
  /// @param _caller          The address initiating the token unloading process and to which ERC20token is assigned to.
  /// @param _from            The address from which the token is being unloaded and removed.
  /// @param _tokenId         Identifier of the PBM token types being unloaded.
  /// @param _amount          The quantity of the corresponding unloaded tokens.
  /// @param _ERC20Token      The address of the underlying ERC-20 token.
  /// @param _ERC20TokenValue The amount of unloaded underlying ERC-20 tokens transferred.
  event TokenUnload(address _caller, address _from, uint256 _tokenId, uint256 _amount, address _ERC20Token, uint256 _ERC20TokenValue);
}

```

## Rationale

This paper extends the [ERC-1155](./eip-1155.md) standards in order to enable easy adoption by existing wallet providers. Currently, most wallet providers are able to support and display ERC-20, ERC-1155 and ERC-721 standards. An implementation which doesn't extend these standards will require the wallet provider to build a custom user interface and interfacing logic which increases the implementation cost and lengthen the time-to-market.

This standard sticks to the push transaction model where the transfer of PBM is initiated on the senders side. Modern wallets can support the required PBM logic by embedding the unwrapping logic within the [ERC-1155](./eip-1155.md) `safeTransfer` function.

### Customisability

Each ERC-1155 PBM Token would map to an underlying `PBMToken` data structure that implementers are free to customize in accordance to the business logic.

By mapping the underlying ERC-1155 token model with an additional data structure, it allows for the flexibility in the management of multiple token types within the same smart contract with multiple conditional unwrapping logic attached to each token type which reduces the gas costs as there is no need to deploy multiple smart contracts for each token types.

1. This EIP makes no assumption on access control and under what conditions can a function be executed. It is the responsibility of the PBM Creator to determine what a user is able to do and the conditions by which a asset is consumed.

2. The event notifies subscribers who are interested to learn whenever an PBM Token is being consumed.

3. To keep it simple, this standard *intentionally* omits functions or events related to the creation of a consumable asset. because of XYZ

4. Metadata associated to the consumables is not included the standard. If necessary, related metadata can be created with a separate metadata extension interface, e.g. `ERC721Metadata` from [EIP-721](./eip-721.md). Refer to [Opensea](https://docs.opensea.io/docs/metadata-standards) for an implementation example.

5. It is **OPTIONAL** to include an parameter `address consumer` for `consume` and `isConsumableBy` functions so that an NFT **MAY** be consumed for someone other than the transaction initiator.

6. It is **OPTIONAL** to include an extra `_data` field to cater for future extension(s), such as
adding crypto endorsements.

## Backwards Compatibility

This interface is designed to be compatible with [ERC-1155](./eip-1155.md).

## Reference Implementation

Reference implementations can be found in [`README.md`](../assets/eip-pbmrc1/README.md).

## Security Considerations
<!-- TBD Improvement: Think of other security considerations + Read up other security considerations in various EIPS and add on to this.  Improve grammer, sentence structure -->

- Malicious users may attempt to:

  - clone existing PBM Tokens to perform double-spending;
  - create invalid PBM Token with no underlying Spot Token; or
  - falsifying the face value of PBM token through wrapping of fraudulent/invalid/worthless Spot Tokens.

- Compliant contracts should pay attention to the balance change for each user when a token is being consumed or minted.

- If PBM Tokens are sent to a recipient wallet that is not compatible with PBM Wrapper the transaction **MUST** fail and PBM Tokens should remain in the sender's PBM Wallet.

- To ensure consistency, when the contract is being suspended, or a user is being restricted from transferring a token, due to suspected fraud, erroneous transfers etc, similar restrictions **MUST** be applied to the user's requests to unwrap the PBM Token.

- Security audits and tests should be performed to verify that unwrap logic behaves as expected or if any complex business logic is being implemented that involves calling an external smart contract to prevent re-entrancy attacks and other forms of call chain attacks.

- This EIP depends on the security soundness of the underlying book keeping behavior of the token implementation.

  - The PBM Wrapper should be carefully designed to ensure effective control over permission to mint a new token. Failing to safeguard permission to mint a new PBM Token can cause fraudulent issuance and and unauthorised inflation of total token supply.

  - The mapping of each PBM Tokens to the amount of underlying spot token held by the smart contract should be carefully accounted for and audited.

- It is recommended to adopt a token standard that is compatible with ERC-20. Examples of such compatible tokens includes tokens implementing ERC-777 or ERC-1363. However, ERC-20 remains the most widely accepted because of its simplicity and there is a high degree of confidence in its security.

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).
