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
        cashoutLendor: null
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
        if (this.state.chainid === 3){
            _chainID = 3;
        }
        if (this.state.chainid === 1337){
            _chainID = "dev"
        }
        const marginFactory = await this.loadContract(_chainID, "MarginFactory")

        if (!marginFactory) {
            return
        }

        const daysInContract = await marginFactory.methods.getDaysInContract().call()
        console.log(accounts[0])
        const balance = await marginFactory.methods.getBalance(accounts[0]).call()
        console.log(balance)
        console.log(marginFactory.options.jsonInterface)
        const addressToAmountFunded = marginFactory.addressToAmountFunded
        const initStartTimestamp = await marginFactory.methods.getInitStateDate().call()
        const initStartDate = initStartTimestamp
        const initStartDateStr = initStartDate
        console.log(initStartDateStr)

        this.setState({
            marginFactory,
            daysInContract,
            balance,
            addressToAmountFunded,
            initStartDateStr
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
                    cashoutLendor: await marginFactory.methods.viewCashoutLendor().call()
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
            marginForLender,
            marginForLessee,
            rentFee,
            maxDaysContract,
            harvestDay,
            testingDays,
            transactionHash,
            balance,
            addressToAmountFunded,
            initStartDateStr
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
            <h1>Margin Factory</h1>
            <div>The init start date is {initStartDateStr}.</div><br/>
            <div>The current address to amount funded is {addressToAmountFunded}.</div><br/>
            <div>The current balance is {balance}.</div><br/>
            <div>Days in Contract: {daysInContract}.</div><br/>
            <div>Cash Out Lendor: {cashoutLendor}.</div><br/>
            <br/>
            <form onSubmit={(e) => this.changeAttributes(e)}>
                <div>
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