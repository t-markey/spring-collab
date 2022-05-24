from brownie import accounts, MarginFactory
import os


def deploy_the_lease():

    # ============Participants============

    blockchain_lawyer = accounts[0]
    # print(account_lendor)

    # Two tester accounts
    #account_lendor = accounts.add(os.getenv("PRIVATE_LANDLORD"))
    #account_lessee = accounts.add(os.getenv("PRIVATE_RENTER"))
    # print(account_lendor)
    # print(account_lessee)
    account_lendor = accounts[1]
    account_lessee = accounts[2]

    # ============Init New contract defaults============

    # Variables
    minimumMarginLendor = 7500000000000000
    minimumMarginLessee = 7500000000000000
    rentFee = 75000000000000000
    maxDaysContract = 120
    harvestDay = 90
    testingDays = 60

    # Deploy Contract and store as Object
    contract_object = MarginFactory.deploy({"from": blockchain_lawyer})
    print(contract_object)

    # Setting the Contract Details (either party can do this)
    # Needs to be fixed so that once margin is posted, it cannot be changed
    # minimumMarginLendor, minimumMarginLessee, rentFee, maxDaysContract, harvestDay, testingDays
    terms_and_conditions = contract_object.setAttributes(
        minimumMarginLendor, minimumMarginLessee, rentFee, maxDaysContract, harvestDay, testingDays, {"from": blockchain_lawyer})

    # Funding the contract
    transact_margin_lendor = contract_object.lendorMargin(
        {"from": account_lendor, "value": minimumMarginLendor})
    print("Lendor posted margin amount :", transact_margin_lendor.info())

    transact_margin_lessee = contract_object.leseeMarginRent(
        {"from": account_lessee, "value": minimumMarginLessee + rentFee})
    print("Lessee posted margin amount :", transact_margin_lessee.info())

    # Loop over all days on contract
    """
    for day in range(121):
        terms_and_conditions = contract_object.setAttributes(
            7500000000000000, 7500000000000000, 75000000000000000, 120, 90, day, {"from": blockchain_lawyer})
        days_elapsed_in_contract = contract_object.getDaysInContract()
        print("Days in contract: ", days_elapsed_in_contract)
    """


def main():
    deploy_the_lease()
