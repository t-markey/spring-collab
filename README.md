# Chainlink/Solana 2022 Hackathon Submission : Block Garden
* Building a landleasing agreement ecosystem for smaller suburban plots of land to utilize empty space and increase local food production.
* The contract requires margin to be posted by each party which is transferred to the other party if one is to void the contract for any reason if they are not satisfied with the arrangement.
* If either Party voids before a pre-determined Harvest date, bother parties loose their margins and it is donated to a charity.  If the void occurs after the harvest date, the voiding parties margin is transferred to the other participant in the lease.


## Roadmap Checkpoints
The Current state is as follows:
* Almost all Basic functionality laid out in the design doc have been implemeted and manually tested
* Automated test estimated to be around 60%
* Chainklink Keepers Utilization mocked up in archive/remix_testing/margin_with_link.sol
* Web3 Ui with React Mix has been started and tested on both Ropsten and Rinkeby (Not all functionality is implemented here.  It also is deployed such that one account funds both parties for ease of testing)
----- 
* 03  JUN  TBD - (Wrap up / Discuss any Further Developement Plans)

## Next Steps
* Finish Unit tests for cashout and void functions
* Obvious Audit Risks - setAttribute functions, more modifiers
* Fix factory function working as expected to keep track of all instances of contracts
* Finish Chainlink Keepers Implementaion

* Web3 stuff - Add buttons for Funding, Voids, Cashouts, Balances, Multiple User End to End testing


## Test Concept Block-Garden
Small Land-leasing contracts verifed via chainlink funded by Solana
![diagram](diagram.png)

## Prototype Contract
Sample contract with variables.
![diagram](sample_contract_image.png)

### Installation
Installing pipx
```bash
brew install pipx
```
Installing brownie [Link](https://eth-brownie.readthedocs.io/en/latest/install.html)
```bash
pipx install eth-brownie
```
Alternative Installation of brownie using pipenv (encountered error brownie using pyhotn 3.1)
```bash
pipenv --python 3.8
pipenv shell
pipenv install eth-brownie
```
Installing ganache-cli
```bash
npm install -g ganache-cli
```
Adding ganache as a test network
```bash
brownie networks add Ethereum ganache host=http://localhost:8545 chainid=1337
```
Running base tests (run commands in multiple terminals)
```bash
	npx ganache-cli
	brownie test —network ganache
```

Running Tests
``` bash
brownie test
```
Also to be noted that in the deploy.py , this is being funded automatically with one account.  In remix the work flow is easier to see by funding the margins with seperate accounts.  The setAttributes function is currently used to iterate over days of the contract. getDaysInContract() needs to be uncommented to go live.
----- 

Running the Web3 client locally from deployment
You will need to make a .env file to store Infura Node and Private metamask wallet key
```bash
	brownie run scripts/deploy.py
```

```bash
cd client
yarn start 
```

## Useful links
* How to Deply a smart contract [with brownie](https://www.quicknode.com/guides/web3-sdks/how-to-deploy-a-smart-contract-with-brownie)
* Brownie [Documentation](https://eth-brownie.readthedocs.io/en/stable/init.html#creating-an-empty-project)
* Brownie mix with [github actions](https://github.com/brownie-mix/github-actions-mix)
[Installing](https://eth-brownie.readthedocs.io/en/latest/install.html) brownie
* Smart contract bootcamp: [brownie track](https://chain.link/bootcamp/brownie-setup-instructions)
* Brownie mix with [chainlink](https://github.com/smartcontractkit/chainlink-mix)
* Basic python web3 library [tutorial](https://www.youtube.com/watch?v=pZSegEXtgAE)
* Web3 library [documentation](https://web3py.readthedocs.io/en/stable/quickstart.html#quickstart)
* Quick Solidity [Reference](https://learnxinyminutes.com/docs/solidity/)
* Reference on [factory patterns](https://betterprogramming.pub/learn-solidity-the-factory-pattern-75d11c3e7d29)
----- 
* Solana [Documentation](https://docs.solana.com)
* Chainklink [Documentation](https://docs.chain.link/?_ga=2.124500034.993353181.1649598364-607422185.1649598364)
* [Anchor](https://project-serum.github.io/anchor/getting-started/introduction.html), abstracts away complexities of smart contracts with Solana Sealevel runtime [install](https://book.anchor-lang.com/chapter_2/installation.html)
----- 
* Hackathon Specific [Documentation/ tutorial / boilerplate](https://docs.chain.link/docs/hackathon-resources/?_ga=2.212595676.993353181.1649598364-607422185.1649598364)
* The Chainlink Hackathon [Main Site](https://chain.link/hackathon) with calendar and rules
* The 16 hour solidity smart contract [tutorial](https://www.youtube.com/watch?v=M576WGiDBdQ)
* Last Seasons winners for reference [fall 2021](https://chain.link/hackathon/hackathon-2021-fall) & [previous hackathons](https://docs.chain.link/docs/example-projects/)
* Solana's novel attributes described: e.g. [proof of history](https://medium.com/solana-labs/proof-of-history-a-clock-for-blockchain-cf47a61a9274)
* Solana version of etherscan : [Solana Explorer](https://explorer.solana.com)
----- 
* Basic smart contract that displays how many times you access it [Here](https://blog.chain.link/how-to-build-and-deploy-a-solana-smart-contract/)
* Simple Tutorial to send yourself test Solanas [Here](https://docs.google.com/document/d/e/2PACX-1vTf4o3Va9TrwsFpYDnTLB8LpIwK1MUh0WIBtajio-Jk78aWlIKF-87BfFdRG2HcfExIq3WIFut_IwdA/pub?_hsmi=208190576&_hsenc=p2ANqtz--PLMIpMAPLBYFfEOVK21XVo822ctPlhBLHs1RawAvQynS-Dzg9rcNDgR0ZKX_3Ek3VKWHo-wWTegOX9-a8Vg6BcHROYA)
* Web3 Setting up Ropsten and Metamask [Here](https://blog.finxter.com/create-web-frontend-using-brownie-react-mix/) 
* All you need smart contract resource [Learn x in y minutes](https://learnxinyminutes.com/docs/solidity/)
------


## Land Leasing Sample contract
[California Farm Link: Model Short Term Crop Lease Agreement](https://farmlandinfo.org/sample_documents/california-farm-link-model-short-term-crop-lease-agreement/)

## License
[MIT](https://choosealicense.com/licenses/mit/)

