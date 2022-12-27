pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import "./Fund.sol";
contract FundFactory is ReentrancyGuardUpgradeable{
    address[] private funds;
    uint private number; 

    event Start(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );

   

  function launch(uint duration,address payable token,uint _goal, uint32 _startAt, uint32 _endAt,uint value) external {
        require(_startAt >= block.timestamp,"Start time is less than current Block Timestamp");
        require(_endAt > _startAt,"End time is less than Start time");
        require(_endAt <= block.timestamp + duration, "End time exceeds the maximum Duration");

        number += 1;
        Fund fund = new Fund();
        fund.initialize(token, duration,_goal,msg.sender,_startAt,_endAt,value);

        

        emit Start(number,msg.sender,_goal,_startAt,_endAt);
    }

  function getDeployedCampaigns() 
  public view returns (address[]  memory){
    return funds;
  }
  
  /** Setter functions */
  function addDeployedFund(address newFund) private {
    funds.push(newFund);
  }

}
