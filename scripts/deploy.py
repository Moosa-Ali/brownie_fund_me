from brownie import FundMe, MockV3Aggregator, network, accounts
from scripts.helper_functions import *


def deploy_fund_me():
    """Function automatically gets correct account and then deploys the respective contract"""

    # get account address according whether we are on the development or live network
    account = get_account()
    if (
        network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS
    ):  # if we are on a live network like rinkeby

        print("Currently running on a live blockchain...")
        priceFeed_address = config["networks"][network.show_active()][
            "eth_usd_priceFeed"
        ]  # get address from config file

    else:

        print("Currently running on a local network...")
        deploy_mocks(account)
        priceFeed_address = MockV3Aggregator[-1].address
    # pass priceFeed address to the constructor of the contract
    fund_me_contract = FundMe.deploy(priceFeed_address, {"from": account})
    print("Contract deployed to address:", fund_me_contract.address)

    # returning contract so our test functions can access it.
    return fund_me_contract


def main():
    deploy_fund_me()
