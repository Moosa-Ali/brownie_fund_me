from brownie import MockV3Aggregator, network, accounts, config
from web3 import Web3


DECIMALS = 8
STARTING_VALUE = 200000000000

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]


def get_account():
    """Function checks whether we are working in a development network or actual blockchain
        and returns an account address accordingly

    Returns:
        Address: Address of the account to make a deployment on the blockchain
    """
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        print("Returning a local network account address...")
        print(accounts[0])
        return accounts[0]
    else:
        print("Returning address of live metamask wallet...")
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks(account):
    """Function deploys any mock contracts that exist if we are on the development network

    Args:
        account (address): address returned from the get_address function

    """

    print("The active network is:", network.show_active())
    print("Deploying mock contracts...")
    agg_contract = MockV3Aggregator.deploy(
        DECIMALS, Web3.toWei(STARTING_VALUE, "ether"), {"from": account}
    )

    print("Mock Aggregator deployed at the address:", agg_contract.address)
