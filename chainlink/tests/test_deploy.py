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
