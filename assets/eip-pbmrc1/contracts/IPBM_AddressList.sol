// SPDX-License-Identifier: MIT
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