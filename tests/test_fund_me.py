from scripts.helper_functions import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account
from scripts.deploy import deploy_fund_me
from brownie import network, accounts, exceptions
import pytest


def test_can_fund_and_withdraw():
    account = get_account()
    fund_me = deploy_fund_me()
    entrance_fee = fund_me.getEntranceFee()
    tx = fund_me.fund({"from": account, "value": entrance_fee})
    tx.wait(1)

    assert fund_me.addressToAmountFunded(account.address) == entrance_fee

    tx2 = fund_me.withdraw({"from": account})
    tx2.wait(1)

    # ensure amount is set to zero after it has been withdrawn
    assert fund_me.addressToAmountFunded(account.address) == 0


def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        # pytest allows us to skip any internal errors thaty solidity raises
        # so our test can run
        pytest.skip(
            "Only for local testing, please change to appropriate network chain"
        )

    account = get_account()
    fund_me = deploy_fund_me()
    bad_actor = accounts.add()

    # pytest allows us to skip any internal errors thaty solidity raises
    # so our test can run
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.withdraw({"from": bad_actor})
