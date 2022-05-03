from brownie import (
    accounts,
    network,
    config,
    Contract,
)

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ['ganache-cli', 'development', 'local']


def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    if id:
        return accounts.load(id)
    return accounts.add(config["wallets"]["from_key"])
