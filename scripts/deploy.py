from brownie import accounts, DappToken, TokenFarm, config, network

from scripts.helpful_scripts import get_account
from web3 import Web3

amount = Web3.toWei(1000000000000, 'ether')


def deploy_token_farm():
    account = get_account()
    dapp_token = DappToken.deploy(
        amount,
        {"from": account},
        publish_source=config[
            'networks'][network.show_active()]['verify'])
    token_farm = TokenFarm.deploy(
        dapp_token.address,
        {"from": account},
        publish_source=config[
            'networks'][network.show_active()]['verify'])


def main():
    deploy_token_farm()
