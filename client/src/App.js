import React, {Component} from "react"
import './App.css'
import {getWeb3} from "./getWeb3"
import map from "./artifacts/deployments/map.json"
import {getEthereum} from "./getEthereum"

class App extends Component {

    state = {
        web3: null,
        accounts: null,
        chainid: null,
        marginFactory: null,
        daysInContract: 0,
        marginForLender: 0,
        marginForLessee: 0,
        rentFee: 0,
        maxDaysContract: 0,
        harvestDay: 0 ,
        testingDays: 0,
        transactionHash: null,
        balance: null,
        addressToAmountFunded: null,
        initStartDateStr: null,
        cashoutLendor: null,
        cashoutLessee: null
    }

    componentDidMount = async () => {

        // Get network provider and web3 instance.
        const web3 = await getWeb3()

        // Try and enable accounts (connect metamask)
        try {
            const ethereum = await getEthereum()
            // ethereum.enable()
            ethereum.request({ method: 'eth_requestAccounts' });
        } catch (e) {
            console.log(`Could not enable accounts.
            Interaction with contracts not available.
            Use a modern browser with a Web3 plugin to fix this issue.`)
            console.log(e)
        }

        // Use web3 to get the users accounts
        const accounts = await web3.eth.getAccounts()

        // Get the current chain id
        const chainid = parseInt(await web3.eth.getChainId())

        this.setState({
            web3,
            accounts,
            chainid
        }, await this.loadInitialContracts)

    }

    loadInitialContracts = async () => {
        const {accounts} = this.state
        var _chainID = 0;
        if (this.state.chainid === 4){
            _chainID = 4;
        }
        if (this.state.chainid === 1337){
            _chainID = "dev"
        }
        const marginFactory = await this.loadContract(_chainID, "MarginFactory")

        if (!marginFactory) {
            return
        }

        const daysInContract = await marginFactory.methods.getDaysInContract().call()
        const cashoutLendor = await marginFactory.methods.viewCashoutLendor().call()
        const cashoutLessee = await marginFactory.methods.viewMarginRemainsLessee().call()
        console.log(accounts[0])
        const balance = await marginFactory.methods.getBalance(accounts[0]).call()
        console.log(balance)
        console.log(marginFactory.options.jsonInterface)
        const addressToAmountFunded = marginFactory.addressToAmountFunded
        const initStartTimestamp = await marginFactory.methods.getInitStateDate().call()
        const initStartDate = initStartTimestamp
        const initStartDateStr = initStartDate
        console.log(initStartDateStr)
        const l_test =  await marginFactory.minimumMarginLendor
        console.log(l_test)

        this.setState({
            marginFactory,
            daysInContract,
            cashoutLendor,
            cashoutLessee,
            balance,
            addressToAmountFunded,
            initStartDateStr,
            l_test
        })
    }

    loadContract = async (chain, contractName) => {
        // Load a deployed contract instance into a web3 contract object
        const {web3} = this.state

        // Get the address of the most recent deployment from the deployment map
        let address
        try {
            address = map[chain][contractName][0]
        } catch (e) {
            console.log(`Could not find any deployed contract "${contractName}" on the chain "${chain}".`)
            return undefined
        }

        // Load the artifact with the specified address
        let contractArtifact
        try {
            contractArtifact = await import(`./artifacts/deployments/${chain}/${address}.json`)
        } catch (e) {
            console.log(`Failed to load contract artifact "./artifacts/deployments/${chain}/${address}.json"`)
            return undefined
        }

        return new web3.eth.Contract(contractArtifact.abi, address)
    }

    changeAttributes = async (e) => {
        const {
            accounts,
            marginFactory,
            marginForLender,
            marginForLessee,
            rentFee,
            maxDaysContract,
            harvestDay,
            testingDays,
        } = this.state
        e.preventDefault()
        const marginForLenderValue = parseInt(marginForLender)
        const marginForLesseeValue = parseInt(marginForLessee)
        const rentFeeValue = parseInt(rentFee)
        const maxDaysContractValue = parseInt(maxDaysContract)
        const harvestDayValue = parseInt(harvestDay)
        const testingDaysValue = parseInt(testingDays)
        if (isNaN(marginForLenderValue)) {
            alert("invalid value")
            return
        }
        await marginFactory.methods.setAttributes(
            marginForLenderValue,
            marginForLesseeValue,
            rentFeeValue,
            maxDaysContractValue,
            harvestDayValue,
            testingDaysValue
        ).send({from: accounts[0]})
            .on('transactionHash', async (transactionHash) => {
                this.setState({ transactionHash })
            })
            .on('receipt', async () => {
                this.setState({
                    daysInContract: await marginFactory.methods.getDaysInContract().call(),
                    cashoutLendor: await marginFactory.methods.viewCashoutLendor().call(),
                    cashoutLessee: await marginFactory.methods.vviewMarginRemainsLessee().call()
                })
            })
    }

    render() {
        const {
            web3,
            accounts,
            marginFactory,
            daysInContract,
            cashoutLendor,
            cashoutLessee,
            marginForLender,
            marginForLessee,
            rentFee,
            maxDaysContract,
            harvestDay,
            testingDays,
            transactionHash,
            balance,
            addressToAmountFunded,
            initStartDateStr,
            l_test
        } = this.state

        if (!web3) {
            return <div>Loading Web3, accounts, and contracts...</div>
        }

        if (!marginFactory) {
            return <div>Could not find a deployed contract. Check console for details.</div>
        }

        const isAccountsUnlocked = accounts ? accounts.length > 0 : false

        return (<div className="App">
           {
                !isAccountsUnlocked ?
                    <p><strong>Connect with Metamask and refresh the page to
                        be able to edit the storage fields.</strong>
                    </p>
                    : null
            }
            <img src= "/images/top_img.jpeg" alt = "Garden"/>
            <h1>Block - Garden</h1>
            <p>Rent your extra land out today!<br/>
            Worried about Pesky Neightbors complaining? or Untidy land renters?<br/>
            Our novel approach to land-leasing contracts allows you to get out anytime!<br/><br/></p>
            <img src= "/images/block_garden.jpeg" alt = "Garden Image"/>
            <h2>Contract Details</h2>
            <div>The Contract started : {initStartDateStr}</div><br/>
            <div>Margin Requirement Lendor : {l_test}</div><br/>
            <div>Margin Requirement Renter : {marginForLender}</div><br/>
            
            <div>Your Current Funding :{addressToAmountFunded}</div><br/>
            <div>(Testing) Whole Contract Balance : {balance}</div><br/>
            <div>Days in Contract : {daysInContract}</div><br/>
            <div>Cash Out Lendor : {cashoutLendor}</div><br/>
            <div>Cash Out Renter : {cashoutLessee}</div><br/>
            <br/>
            <form onSubmit={(e) => this.changeAttributes(e)}>
                <div>
                <h2>Set Contract Details</h2>
                    <label>Margin for lender:</label>
                    <input
                        name="marginForLender"
                        type="text"
                        value={marginForLender}
                        onChange={(e) => this.setState({marginForLender: e.target.value})}
                    />.<br/>
                    <label>Margin for lessee:</label>
                    <input
                        name="marginForLessee"
                        type="text"
                        value={marginForLessee}
                        onChange={(e) => this.setState({marginForLessee: e.target.value})}
                    />.<br/>
                    <label>Rent fee:</label>
                    <input
                        name="rentFee"
                        type="text"
                        value={rentFee}
                        onChange={(e) => this.setState({rentFee: e.target.value})}
                    />.<br/>
                    <label>Max days in contract:</label>
                    <input
                        name="maxDaysContract"
                        type="text"
                        value={maxDaysContract}
                        onChange={(e) => this.setState({maxDaysContract: e.target.value})}
                    />.<br/>
                    <label>Harvest day:</label>
                    <input
                        name="harvestDay"
                        type="text"
                        value={harvestDay}
                        onChange={(e) => this.setState({harvestDay: e.target.value})}
                    />.<br/>
                    <label>Testing days:</label>
                    <input
                        name="testingDays"
                        type="text"
                        value={testingDays}
                        onChange={(e) => this.setState({testingDays: e.target.value})}
                    />.<br/>
                    <p>
                        <button type="submit" disabled={!isAccountsUnlocked}>Submit</button>
                    </p>
                </div>
            </form>
            <img src= "/images/footer_img.jpeg" alt = "Garden Image 2"/>
            <br/>
            {transactionHash ?
                <div>
                    <p>Last transaction Hash: {transactionHash}</p>
                </div>
            : null
            }
        </div>)
    }
}

export default App