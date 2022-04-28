// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract LeaseMargins{

    // Map address sending funds to 
    mapping(address => uint256) public addressLendorToAmountFunded;
    mapping(address => uint256) public addressLesseeToAmountFunded;
    
    // True when margin has been funded
    bool lendorMarginOk = false;
    bool lesseeMarginOk = false;

    // Contract voided when either are true (Margin Forfeited by voiding party)
    bool lendorVoid = false;
    bool lesseeeVoid = false;
    
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
    // Returns 0 if contract is void
    function getDaysInContract() public view returns(uint){
        if (lendorMarginOk && lendorMarginOk){
            return (block.timestamp - chainStartTime )/ 86400;
        }  
        else{
            return 0;
        }
    }



    // ***NEEDS WORK
    // ============End Contract via keyphrase(Or amend later on)============
    // If a string is sent by either address contract is void
    // String could be an explanation on why they ended the contract
    // This would be added to finalized voided contract uploaded to ipfs
    string keyPhrase;
    function store(string memory _keyPhrase) public{
        keyPhrase = _keyPhrase;
        /*
        if(SENDER ADDRESS = LENDOR){
            if (keyPhrase = "get info") // get days until lease ends & other info
            if (keyPhrase = "cash out") // get current equity in the contract (pay your own gas!)
            if ("void"in keyPhrase) // voids contract, can optionally include explanation
        }
        if(SENDER ADDRESS = LESSEE){
            if (keyPhrase = "get info") // get days until lease ends & other info
            if ("void"in keyPhrase) // voids contract, can optionally include explanation
        }
        */
    }











}
