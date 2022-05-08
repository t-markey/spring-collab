// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;


contract LandLease{

    struct Lease {
        string contract_alias;
        string type_of_contract;
        int256 latitude;
        int256 longitude;
        uint256 rent;
        uint256 total_days;
    }

    struct Lendor{
        bool satisfaction;
        uint256 margin;
        address public_lender_address;
    }

      struct Lessee{
        bool satisfaction;
        uint256 margin;
        address public_lender_address;
    }


    struct Escrow_party{  
        address public_escrow_address;
    }

    //Hardcoded intitializing
    Lease public nj = Lease({contract_alias: "local kale patch",type_of_contract :"private residence", latitude :40, longitude : -70, rent : 200, total_days : 180});

    //Dynamic Array of all leases
    Lease[] public lease;

    // Allows you to input a lease agreement manually
    function addLease(string memory _contract_alias, string memory _type_of_contract, int256 _latitude,int256 _longitude, uint256 _rent, uint256 _total_days ) public{
        lease.push(Lease(_contract_alias, _type_of_contract, _latitude, _longitude, _rent, _total_days));
    }


  

}
