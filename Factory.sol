pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import "./Fund.sol";

/*
  The FundFactory smart contract is used to create Fund Contracts. The Factory pattern 
  was imlemented for feasible scalability. In a crowdfunding contract thousands of
  funds can be created with thouands of addresses in each fund and this results in
  the tracking in a single smart contract tedious. Hence we generate a different
  contract for each variation of Fund and track the data in each fund separately. The
  contract is ugradeable so that any logic in the creation of Funds can be changed if
  required.
*/
contract FundFactory is ReentrancyGuardUpgradeable{
    
    mapping(uint=>address) private funds;//Contains all the generated fund contracts.
    uint256 private number; //Kees count o number of funds generated.
    event Create(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );

   
  /*
   This method is used to create the Fund smart contracts. The validation of the attributes
   of the Fund contract also occurs in this method. Once a contract is created the
   required data is updated.
  */
  function launch(uint duration,address payable token,uint _goal, uint32 _startAt, uint32 _endAt,uint value) external {
        //require(_startAt >= block.timestamp,"Start time is less than current Block Timestamp");
        //require(_endAt > _startAt,"End time is less than Start time");
        //require(_endAt <= block.timestamp + duration, "End time exceeds the maximum Duration");

        number += 1;
        Fund fund = new Fund(token, duration,_goal,msg.sender,_startAt,_endAt,value,number);
         
        addDeployedFund(address(fund),number);

        emit Create(number,msg.sender,_goal,_startAt,_endAt);
    }

  /*
  Returns the number of deployed Fund contracts.
  */
  function getDeployedFundsCount() 
   public view returns (uint256){
     return number;
   } 
  
  /** Adds the newly created Fund contract to Fund contract mapping */
  function addDeployedFund(address newFund,uint256 num) private {
    funds[num]=newFund;
  }

  /*Returns the address using the contract number. */
  function getDeployedFund(uint256 num) public view returns(address) {
    return funds[num];
  }

}
