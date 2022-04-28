// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract LeaseMargins{

    // Map address sending funds to 
    mapping(address => uint256) public addressLendorToAmountFunded;
    mapping(address => uint256) public addressLesseeToAmountFunded;
    
    // True when margin has been funded
    bool lendorMarginOk = false;
    bool lesseeMarginOk = false;
    
    // Global variable for start time of contract
    uint chainStartTime = 0;


    //address escrow_address;
    // Constructor for Contract Admin
    // Immediately executed when contract is deployed
    //constructor() public {}
    

    // ============Margin posting for Lendor============
    // ***NEEDS Dynamic input of 1 margin value
    // ***NEEDS Return confirmation value
    // ***NEEDS Verify These are funds from Lendor
    function lendorMargin() public payable{

        //min hardcoded 20 USD (0.00034 ETH)
        uint minimumMargin = 6800000000000000;

        //Denies transaction if margin not met
        require(msg.value >= minimumMargin, "Need to deposit the required Margin!");
        addressLendorToAmountFunded[msg.sender] += msg.value;

        //logic to set start Date if both Margins are retained
        if (msg.value >= minimumMargin) {
            lendorMarginOk = true;
            if (lesseeMarginOk = true){
                chainStartTime = block.timestamp;
            }
        }
      
    }




    // ============Posting of Margin and entire rent by Lessee============
    // ***NEEDS Dynamic input of 2 values
    // ***NEEDS Return confirmation value
    // ***NEEDS Verify These are funds from Lessee
    function lendorMarginRent() public payable{

        //min hardcoded 220 USD (0.075 ETH)
        uint minimumMargin = 75000000000000000;
        //Denies transaction if margin not met
        require(msg.value >= minimumMargin, "Need to deposit the required Margin!");
        addressLesseeToAmountFunded[msg.sender] += msg.value;

        if (msg.value >= minimumMargin) {
            lesseeMarginOk = true;
            if (lendorMarginOk = true){
                chainStartTime = block.timestamp;
            }
        }
    }

    

    // ============Returns Unix timestamp of contract startdate============
    // Use for calculating payoff to lendor if contract is voided
    // Returns 0 if contract hasn't been initiated
    function getInitStateDate() public view returns(uint){
        if (lendorMarginOk && lendorMarginOk){
            return chainStartTime;
        }  
        else{
            return 0;
        }
    }


    // ============Returns Days elapsed since contract elapsed============ 
    //returns 0 if contract is void
    function getDaysInContract() public view returns(uint){
        if (lendorMarginOk && lendorMarginOk){
            return (block.timestamp - chainStartTime )/ 86400;
        }  
        else{
            return 0;
        }
    }






}
