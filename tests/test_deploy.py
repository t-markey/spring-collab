from brownie import accounts, MarginFactory


def test_deploy():
    #
    blockchain_lawyer = accounts[0]
    account_lendor = accounts[1]
    account_lessee = accounts[2]
    #
    contract_object = MarginFactory.deploy({"from": blockchain_lawyer})
    days_elapsed_in_contract = contract_object.getDaysInContract()
    expected = 0
    #
    assert days_elapsed_in_contract == expected

# A time that is not zero confirms the contract has been signed by both parties


def test_fund():
    #
    blockchain_lawyer = accounts[0]
    account_lendor = accounts[1]
    account_lessee = accounts[2]
    #
    contract_object = MarginFactory.deploy({"from": blockchain_lawyer})
    transact_margin_lendor = contract_object.lendorMargin(
        {"from": account_lendor, "value": 7500000000000000})
    transact_margin_lessee = contract_object.leseeMarginRent(
        {"from": account_lessee, "value": 7500000000000000 + 75000000000000000})
    unix_start_time = contract_object.getInitStateDate()
    #
    assert unix_start_time != 0

# Initial Day of Contract, balances margin that when in should display propery with getBalance function from either address


def test_get_balance_startDate():
    #
    blockchain_lawyer = accounts[0]
    account_lendor = accounts[1]
    account_lessee = accounts[2]
    #
    contract_object = MarginFactory.deploy({"from": blockchain_lawyer})
    transact_margin_lendor = contract_object.lendorMargin(
        {"from": account_lendor, "value": 7500000000000000})
    transact_margin_lessee = contract_object.leseeMarginRent(
        {"from": account_lessee, "value": 7500000000000000 + 75000000000000000})
    lendor_balance = 7500000000000000
    lessee_balance = 7500000000000000 + 75000000000000000
    #
    assert lendor_balance == contract_object.getBalance(account_lendor)
    assert lessee_balance == contract_object.getBalance(account_lessee)

# On final day of contract , Lendor should be able to do full cashout rentfee + margin, Lessee only has his margin remaining


def test_Check_cashout_enddate():
    #
    blockchain_lawyer = accounts[0]
    account_lendor = accounts[1]
    account_lessee = accounts[2]
    #
    contract_object = MarginFactory.deploy({"from": blockchain_lawyer})
    terms_and_conditions = contract_object.setAttributes(
        7500000000000000, 7500000000000000, 75000000000000000, 120, 90, 120, {"from": blockchain_lawyer})
    transact_margin_lendor = contract_object.lendorMargin(
        {"from": account_lendor, "value": 7500000000000000})
    transact_margin_lessee = contract_object.leseeMarginRent(
        {"from": account_lessee, "value": 7500000000000000 + 75000000000000000})
    lendor_balance_init = 7500000000000000
    lessee_balance_init = 7500000000000000 + 75000000000000000
    lendor_cash = contract_object.viewCashoutLendor()
    #
    assert lendor_cash == 7500000000000000 + 75000000000000000
    assert 7500000000000000 == contract_object.viewMarginRemainsLessee()


# Testing that funds are indeed transferring partially through a contract
def test_midway_funds_transferring():
    #
    blockchain_lawyer = accounts[0]
    account_lendor = accounts[1]
    account_lessee = accounts[2]
    #
    contract_object = MarginFactory.deploy({"from": blockchain_lawyer})
    terms_and_conditions = contract_object.setAttributes(
        7500000000000000, 7500000000000000, 75000000000000000, 120, 90, 60, {"from": blockchain_lawyer})
    transact_margin_lendor = contract_object.lendorMargin(
        {"from": account_lendor, "value": 7500000000000000})
    transact_margin_lessee = contract_object.leseeMarginRent(
        {"from": account_lessee, "value": 7500000000000000 + 75000000000000000})
    lendor_balance_init = 7500000000000000
    lessee_balance_init = 7500000000000000 + 75000000000000000
    lendor_cash = contract_object.viewCashoutLendor()
    #
    assert lendor_balance_init <= lendor_cash
    assert lessee_balance_init > + contract_object.viewMarginRemainsLessee()


# Iterate throught the entirety of the contract everyday
def test_loop_all_days():
    #
    blockchain_lawyer = accounts[0]
    account_lendor = accounts[1]
    account_lessee = accounts[2]
    #
    contract_object = MarginFactory.deploy({"from": blockchain_lawyer})
    terms_and_conditions = contract_object.setAttributes(
        7500000000000000, 7500000000000000, 75000000000000000, 120, 90, 60, {"from": blockchain_lawyer})
    transact_margin_lendor = contract_object.lendorMargin(
        {"from": account_lendor, "value": 7500000000000000})
    transact_margin_lessee = contract_object.leseeMarginRent(
        {"from": account_lessee, "value": 7500000000000000 + 75000000000000000})

    for day in range(31):
        terms_and_conditions = contract_object.setAttributes(
            7500000000000000, 7500000000000000, 75000000000000000, 30, 15, day, {"from": blockchain_lawyer})
        days_elapsed_in_contract = contract_object.getDaysInContract()
        print("Days in contract: ", days_elapsed_in_contract)


# IF contract unix time is x days > projected end date THEN give back margin
# def test_chainlink_automation():
    # pass
    #
    #
    #
    #assert 0 == contract_object.getBalance(account_lendor)
    #assert 0== contract_object.getBalance(account_lessee)
