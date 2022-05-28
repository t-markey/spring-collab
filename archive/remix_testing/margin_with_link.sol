// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


import "@chainlink/contracts/src/v0.6/interfaces/KeeperCompatibleInterface.sol";


contract LeaseMargins is KeeperCompatibleInterface{

    // Maps value of funds an address has sent
    mapping(address => uint256) public addressToAmountFunded;

    // Lists of Lendor and Lessee Adresses
    address[]  lendorAddress;
    address[]  lesseeAddress;
    
    // True when margin has been funded
    bool lendorMarginOk = false;
    bool lesseeMarginOk = false;

    // Contract voided when either are true (Margin Forfeited by voiding party)
    bool lendorVoid = false;
    bool lesseeVoid = false;
    
    // Global variable for start time of contract
    uint chainStartTime = 0;


    
    //============Default Variables============
    //***NEEDS to instantiate custom values

    //Lender margin requirements
    //min hardcoded 20 USD (0.0075 ETH) (7500000000000000 wei)
    uint minimumMarginLendor = 7500000000000000;

    //Lessee margin requirements
    //min hardcoded 20 USD (0.0075 ETH) (7500000000000000 wei)
    uint minimumMarginLessee = 7500000000000000;
    
    //Lesse total rent 200 USD (0.075 ETH) (75000000000000000 wei)
    uint rentFee = 75000000000000000;

    //Total cost to Lessee to enter the contract (hardcoded at 220 USD)
    //  = 82500000000000000
    uint totalCostLessee = rentFee + minimumMarginLessee;

    //Days for contract to ideally last
    uint maxDaysContract = 120;

    //"Harvest Date" for a binary determinent of who gets to keep margin
    //If before harvest date => both loose margin during a void, after harvest it goes to other party
    // ***NEEDS to be replaced with a function that varies over t, time remaining in contract
    // If before harvest date:
    //      If Lendor voids => Both lose your margin
    //      If Lessee voids => Both lose your margin
    // If after harvest date, Less
    //      if Lendor voids => Lendor Margin goes to Lessee
    //      if Lessee voids => Lessee Margin goes to Lendor
    uint harvestDay = 90;

    /*
    // ============Returns Days elapsed since contract elapsed============
    // Returns 0 if contract is void
    function getDaysInContract() private view returns(uint){
        if (lendorMarginOk && lendorMarginOk){
            return (block.timestamp - chainStartTime )/ 86400;
        }  
        else{
            return 0;
        }
    }
    */


    // TEST FUNCTION TO BE DELETED LATER
    // Set current day for testing 
    // Show's state on contract at any one day
    uint public testingDays = 0;
    function getDaysInContract() public view returns(uint){return testingDays;}


    
    // ===========Override Contract Defaults===========
    // ... =========Set Contract Defaults==============
    // Setting contract details 
    // Function setAttributes
    // ***NEEDS BOOL to stop editting during time (helpful for testing as is )
    function setAttributes(uint _minimumMarginLendor, uint _minimumMarginLessee, uint _rentFee, uint _maxDaysContract, uint _harvestDay, uint _testingDays) public returns(address){
        minimumMarginLendor = _minimumMarginLendor;
        minimumMarginLessee = _minimumMarginLessee;
        rentFee =  _rentFee;
        totalCostLessee = rentFee + minimumMarginLessee;
        maxDaysContract = _maxDaysContract;
        harvestDay = _harvestDay;
        testingDays = _testingDays;

        //show address you are currently modifying
        return  address(this);
    }

    

    // ============Margin posting for Lendor============
    // ***NEEDS Return confirmation value
    // ***NEEDS Verify These are funds from Lendor
    function lendorMargin() public payable{

        //min hardcoded 20 USD by constructor
        uint minimumMargin = minimumMarginLendor;

        //denies transaction if margin not met
        require(msg.value == minimumMargin, "Need to deposit the required Margin!");
        addressToAmountFunded[msg.sender] += msg.value;

        //add Lendor to list for address reference
        lendorAddress.push(msg.sender);

        //logic to set start Date if both Margins are retained
        if (msg.value >= minimumMargin) {
            lendorMarginOk = true;
            if (lesseeMarginOk = true){
                chainStartTime = block.timestamp;
            }
        }
      
    }



    // ============Posting of Margin and entire rent by Lessee============
    // ***NEEDS Return confirmation value
    // ***NEEDS Verify These are funds from Lessee
    function leseeMarginRent() public payable{

        //min hardcoded 220 USD 
        uint minimumMargin = totalCostLessee ;

        //Denies transaction if margin not met
        require(msg.value == minimumMargin, "Need to deposit the required Margin!");
       addressToAmountFunded[msg.sender] += msg.value;

        //add Lendor to list for address reference
        lesseeAddress.push(msg.sender);

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



    // ============Decorates a function to only have Lendor access Permissions============
    modifier onlyLendor{
        require(msg.sender == lendorAddress[0]);
        _;
    }

    // ============Decorates a function to only have Lessee access Permissions============
    modifier onlyLessee{
        require(msg.sender == lesseeAddress[0]);
        _;
    }

    // ============Decorates a function to only run if contract is valid(signed with both margins)============
    modifier contractValid{
        require(lendorMarginOk && lendorMarginOk);
        _;
    }



    // ============Get Current Balances============
    // Given current day computed by getDaysInContract()
    // This function Adjusts theoretical value of each account given all payments that would have occured
    // This is like Daily Settlement, without actually transferring the funds
    // This is to save on the feeds incurred if it were processed each day
    // *Can call this function on either address
    function getBalance(address either)public view returns(uint) {
        //only can get balances of valid relevant addresses
        require (either == lendorAddress[0] || either == lesseeAddress[0]);

        //get how many days contract has been elapsed for 
        //Checks that days to get paid for doesn't exceed the contract max
        uint d = getDaysInContract();
        if ( d > maxDaysContract){
            d = maxDaysContract;
        }

        uint pricePerDay = rentFee /maxDaysContract;
        uint accumFunds = pricePerDay * d;
        
        if (either == lendorAddress[0]){
            uint resultBalance = addressToAmountFunded[lendorAddress[0]] + accumFunds;
            return resultBalance;
        }

        if (either == lesseeAddress[0]){
            if (addressToAmountFunded[lesseeAddress[0]] ==0){return 0;}
            uint resultBalance = addressToAmountFunded[lesseeAddress[0]] - accumFunds;
            return resultBalance;
        }

    }


   
    // ============Allow Lendor to see how much he could cashout for currently============
    // Calls the getBalance function that adjusts for daily payments
    // Adjusts these balances for the harvest date adjustments which relates to retain margin or not
    function viewCashoutLendor() public view returns(uint){
        
        //Before Harvest Date 
        if (getDaysInContract()<harvestDay){
            if (getBalance(lendorAddress[0])== 0){return 0;}
            uint penalty = getBalance(lendorAddress[0]) - minimumMarginLendor;
            return penalty;
        }
        

        //After Harvest Date
        return getBalance(lendorAddress[0]);

    }



    // ============Show the Lessee how much margin he has left posted (diminishes by day)============
    function viewMarginRemainsLessee() public view returns(uint){
        
        //Before Harvest Date 
        if (getDaysInContract()<harvestDay){
            uint penalty = getBalance(lesseeAddress[0]) - minimumMarginLessee;
            return penalty;
        }

        //After Harvest Date
        return getBalance(lesseeAddress[0]);
    }

   

    // ============End Contract Lendor Void============
    function voidingLendor() onlyLendor contractValid payable public{
        
        
        //Update Lendor balance to transfer
        //Lendor loses margin in void they initiate
        msg.sender.transfer(viewCashoutLendor()-minimumMarginLessee);
        addressToAmountFunded[msg.sender] -= viewCashoutLendor();   // Best practice this should be above?

        //Making Lessor's address Payable to access .transfer
        address payable lesseePayable = payable(lesseeAddress[0]);
  
        //Update Lessee balance to transfer
        //Lessee gets the Lendors margin if time is greater than harvest date
        if (getDaysInContract() > harvestDay){
            addressToAmountFunded[lesseeAddress[0]] -= viewMarginRemainsLessee();
            lesseePayable.transfer(viewMarginRemainsLessee() + minimumMarginLessee);
        }
        else{
            lesseePayable.transfer(viewMarginRemainsLessee());
        }

        //Documenting that Lendor voided contract
        lendorVoid = true;

    }



    // ============Lendor Cashout============
    // At any time or after contract has completed
    function cashoutLendor(uint withdrawAmount) onlyLendor contractValid payable public{
        
        // If contract completes without a void, allow full withdrawl of acculated funds and OG margin posted
        // Also gives back margin to Lessee that they had posted
        if (getDaysInContract() >= maxDaysContract){
            msg.sender.transfer(addressToAmountFunded[lendorAddress[0]]+ minimumMarginLendor);
            addressToAmountFunded[lendorAddress[0]] = 0;
            
            //Making Lessor's address Payable to access .transfer
            //Sending them their margin back
            address payable lesseePayable = payable(lesseeAddress[0]);
            lesseePayable.transfer(minimumMarginLessee);
            addressToAmountFunded[lesseeAddress[0]] = 0;

            // Makes contract null after completion
            lendorMarginOk = false;
            lesseeMarginOk = false;
            return;
        }

        // For the time between harvest day and end of contract
        if (harvestDay <= getDaysInContract() && getDaysInContract() < maxDaysContract){
            //check to make sure they don't take more than they have put in 
            require (withdrawAmount <= viewCashoutLendor()- minimumMarginLessee);

            //Update Lendor balance to transfer
            //They will be able to call this multiple times through contract
            addressToAmountFunded[msg.sender] -= withdrawAmount;
            msg.sender.transfer(withdrawAmount);
            return;

        }
        if (getDaysInContract() < harvestDay){

            //check to make sure they don't take more than they have put in 
            require (withdrawAmount <= viewCashoutLendor());

            //Update Lendor balance to transfer
            //They will be able to call this multiple times through contract
            addressToAmountFunded[msg.sender] -= withdrawAmount;
            msg.sender.transfer(withdrawAmount);
            return;
        }

    }



    // ============End Contract Lessee Void============
    function voidingLessee() onlyLessee contractValid payable public{
        
        //Update Lessee balance to transfer
        //Lessee loses margin in void they initiate
        msg.sender.transfer(viewMarginRemainsLessee()-minimumMarginLessee);
        addressToAmountFunded[msg.sender] =0;   // best practice to be above?

        //Making Lendor's address Payable to access .transfer
        address payable lendorPayable = payable(lendorAddress[0]);
  
        //Update Lendor balance to transfer
        //Lendor gets the Lessees margin if time is greater than harvest date
        if (getDaysInContract() > harvestDay){
            lendorPayable.transfer(viewCashoutLendor() + minimumMarginLendor);
            addressToAmountFunded[lendorAddress[0]] -= viewCashoutLendor(); // best practice to be above?
        }
        //Lendor gets rent paid out 
        else{
            lendorPayable.transfer(viewCashoutLendor());
        }

        //Documenting that Lessee voided contract
        lesseeVoid = true;

    }



    // ============Lendor Cashout Completed Contract============
    // Release both margin and all accumulated rent money to the Lendor
    function cashoutLessee() onlyLessee contractValid payable public{
        require (getDaysInContract() >= maxDaysContract);

        //Margin back to Lessee
        msg.sender.transfer(minimumMarginLessee);

        //Making Lendor's address Payable to access .transfer
        address payable lendorPayable = payable(lendorAddress[0]);
        lendorPayable.transfer(viewCashoutLendor());
        
        // Nullify contract
        lendorMarginOk = false;
        lesseeMarginOk = false;

    }
    // ***NEEDS WORK    
    // Function to be called when leftover margin ETH during a pre-Harvest Date void
    // Find Charity to senc it to ? See "the giving block" for interesting or default to red cross







    // If after 5 days of ended contract, no one cashesout
    // Chainlink keepers will automate this .
    // OG margin + rentFee goes to Lender
    // OG margin goes back to Lessee

    // ============Chainlink Keepers============
    //Called by Chainlink Keepers to check if work needs to be done
    function checkUpkeep(
        bytes calldata /*checkData */
    ) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (getDaysInContract()) > maxDaysContract+5;
    }

    
    //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        
        // Checks that no one has voided and contract still valid
        if (lendorVoid == false && lesseeVoid == false){
            //Making Lendor's address Payable to access .transfer
            address payable lendorPayable = payable(lendorAddress[0]);
            lendorPayable.transfer(getBalance(lendorAddress[0]));

            //Sending them their margin back
            address payable lesseePayable = payable(lesseeAddress[0]);
            lesseePayable.transfer(minimumMarginLessee);

             // Nullify contract
            lendorMarginOk = false;
            lesseeMarginOk = false;
        }

        // If contract was voided after harvest date by either
        // The Margins get donated to charity
        // Rainforest Foundation US :
        // 0x338326660F32319E2B0Ad165fcF4a528c1994aCb
        else {
            address payable rainForest = payable(0x338326660F32319E2B0Ad165fcF4a528c1994aCb);
            rainForest.transfer(minimumMarginLessee + minimumMarginLendor);
        }

    }




}
    