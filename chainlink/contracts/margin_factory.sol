// SPDX-License_identifier: MIT

pragma solidity ^0.6.0;

// Import of other contract
import "./margin.sol";



 


// MarginFactory inherits from LeaseMargins
contract MarginFactory is LeaseMargins{

    LeaseMargins[] public leaseStoreArray;

    // Array of all Lease Contracts
    //**** Needs to show accurate addresses??????
    function showAllLease() public view returns(LeaseMargins[] memory){return leaseStoreArray;}
    

    // Instantiates new contracts
    function createLease() public{
        LeaseMargins newLease = new LeaseMargins();
        leaseStoreArray.push(newLease);
    }

    // ==========Setting Values for Tests===========
    // Use the setAttributes function with the following format:
    //minimumMarginLendor, minimumMarginLessee, rentFee, maxDaysContract, harvestDay, testingDays
    //7500000000000000, 7500000000000000, 75000000000000000, 120, 90, 60
    //**** input to target specific addresses.


}