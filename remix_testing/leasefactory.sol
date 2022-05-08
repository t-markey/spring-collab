// SPDX-License_identifier: MIT

pragma solidity ^0.6.0;

// Import of other contract
import "./lease.sol";


// Storage Factory inherits from simpleStorage
contract LeaseFactory is LandLease{

    LandLease[] public leaseStoreArray;

    // Instantiates new contracts
    function createLease() public{
        LandLease newLease = new LandLease();
        leaseStoreArray.push(newLease);
    }









}
