// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenFarm is Ownable {
    //    allowed tokens e:g dai,dapp and more
    address [] public allowedTokens;
    //    giving out  our  token base on amount staked
    //    1 eth => 1dai or 10percent of eth then convert to dai
    //    in 24 hours or something else
    mapping(address => uint256) userStakingBalance;
    //    unique token staked for a user
    //    token => user => amount (in wei)
    mapping(address => mapping(address => uint256)) uniqueTokenStakingBalance;
    //    unique token staked count
    mapping(address => uint256) public uniqueTokensStaked;
    //    getting price of token
    mapping(address => address) public tokenPriceFeedMapping;
    
    //    list of stakers
    address[] public stakers;
    
    //    our unique token we give out after user stake
    IERC20 public dappToken;
    
    constructor (address _dappTokenAddress) {
        dappToken = IERC20(_dappTokenAddress);
    }
    
    //    getting the price of a particular token
    function setTokenPriceFeed(address _token, address _priceFeed) public onlyOwner {
        tokenPriceFeedMapping[_token] = _priceFeed;
    }
    
    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }
    
    function updateUniqueTokensStaked(address _user, address _token) internal {
        if (uniqueTokenStakingBalance[_token][_user] <= 0) {
            uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
        }
    }
    
    function tokenIsAllowed(address _token) public returns (bool){
        for (uint256 allowedTokenIndex = 0; allowedTokenIndex < allowedTokens.length; allowedTokenIndex) {
            if (allowedTokens[allowedTokenIndex] == _token) {
                return true;
            }
        }
        return false;
    }
    
    
    function stakeToken(address _token, uint256 _amount) public {
        require(tokenIsAllowed(_token) == true, "Token is not currently allowed");
        require(_amount > 0, "Amount must be greater than zero");
        //        transfer token to contract
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        //        update the token user staked
        updateUniqueTokensStaked(msg.sender, _token);
        uniqueTokenStakingBalance[_token][msg.sender] += _amount;
    }
    
    //    amount in usd of a token
    function getUserSingleTokenValue(address _token, address _user) public returns (uint256) {
        address _priceFeedAddress = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_priceFeedAddress);
        uint256 decimals = priceFeed.decimals();
        (
        /*uint80 roundID*/,
        int price,
        /*uint startedAt*/,
        /*uint timeStamp*/,
        /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return (
        uniqueTokenStakingBalance[_token][_user] * uint256(price) / (10 ** decimals));
    }
    
    //    unStake token with token amount
    function unStakeToken(address _token, uint256 _amount) public {
        require(tokenIsAllowed(_token) == true, "Token is not currently allowed");
        require(_amount > 0, "Amount must be greater than zero");
        require(_amount >= uniqueTokenStakingBalance[_token][msg.sender], "Amount greater than current balance");
        uniqueTokenStakingBalance[_token][msg.sender] -= _amount;
        uniqueTokensStaked[msg.sender] -= 1;
        IERC20(_token).transfer(msg.sender, _amount);
    }
    
    //    this unStake the current token balance
    function unStakeTokenBalance(address _token) public {
        require(tokenIsAllowed(_token) == true, "Token is not currently allowed");
        require(uniqueTokenStakingBalance[_token][msg.sender] > 0, "Amount must be greater than zero");
        IERC20(_token).transfer(msg.sender, uniqueTokenStakingBalance[_token][msg.sender]);
    }
    
    
    
    //    function calculateUserStakedBonus(address _token) internal returns (uint256) {
    //        for (uint256 index = 0;
    //            index < uniqueTokenStakingBalance < index; index ++) {
    //            if (uniqueTokenStakingBalance[_token][msg.sender] > 0) {
    //
    //            }
    //
    //        }
    //    }
    //
    
}
