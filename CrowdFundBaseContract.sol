pragma solidity ^0.8.0;

contract CrowdFundBaseContract{
     mapping(address=>uint256) public addressMapping;
     mapping(address=>bool) public availabilityMapping;
     address public immutable cftoken;
     bool hasSetToken;
     uint public immutable setBlockNumber=block.number;
     uint public immutable fundDuration;


    constructor(uint256 _fundDuration,address _cftoken){
       fundDuration=_fundDuration;
       cftoken=_cftoken;
    }

    modifier onlyCfToken {
        require(msg.sender == cftoken, "Only the assigned CF Token can perform this action");
        _;
    }

    modifier onlyTokenNotSet {
        require(hasSetToken == false, "The token has already been set");
        _;
    }


     function addAmount(address user,uint256 amount) public onlyCfToken{
         if(!availabilityMapping[user])
         {
            availabilityMapping[user]=true;
            addressMapping[user]=amount;
         }
         else
         {
            addressMapping[user]=addressMapping[user]+amount;
         }
     }
}
