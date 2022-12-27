pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import "./CFToken.sol";
contract Fund is ReentrancyGuardUpgradeable{
    
    struct crowdFund{
        string key;
        uint goal;
        address beneficiary;
        bool isOver;
        uint opening;
        uint closing;
        uint value;
    }

    uint public number;
    CFToken public token;
    uint public duration;
    mapping(uint => crowdFund) public funds;
    mapping(uint => mapping(address => uint)) public contributions;

     event Start(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );

    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

     function initialize(address payable _token, uint _duration) 
  public     {
      token = CFToken(_token);
      duration=_duration;
  }

  function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp,"Start time is less than current Block Timestamp");
        require(_endAt > _startAt,"End time is less than Start time");
        require(_endAt <= block.timestamp + duration, "End time exceeds the maximum Duration");

        number += 1;
        funds[number] = crowdFund({
            beneficiary: msg.sender,
            goal: _goal,
            value: 0,
            opening: _startAt,
            closing: _endAt,
            isOver: false,
            key:"Plus"
        });

        emit Start(number,msg.sender,_goal,_startAt,_endAt);
    }

    function cancel(uint _id) external {
        crowdFund memory fund = funds[_id];
        require(fund.beneficiary == msg.sender, "You did not create this Campaign");
        require(block.timestamp < fund.opening, "Campaign has already started");

        delete funds[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        crowdFund storage fund = funds[_id];
        require(block.timestamp >= fund.opening, "Campaign has not Started yet");
        require(block.timestamp <= fund.closing, "Campaign has already ended");
        fund.value += _amount;
        contributions[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unPledge(uint _id,uint _amount) external {
        crowdFund storage fund = funds[_id];
        require(block.timestamp >= fund.opening, "Campaign has not Started yet");
        require(block.timestamp <= fund.closing, "Campaign has already ended");
        require(contributions[_id][msg.sender] >= _amount,"You do not have enough tokens Pledged to withraw");

        fund.value -= _amount;
        contributions[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        crowdFund storage fund = funds[_id];
        require(fund.beneficiary == msg.sender, "You did not create this Campaign");
        require(block.timestamp > fund.closing, "Campaign has not ended");
        require(fund.value >= fund.goal, "Campaign did not succed");
        require(!fund.isOver, "claimed");

        fund.isOver = true;
        token.transfer(fund.beneficiary, fund.value);

        emit Claim(_id);
    }

    function refund(uint _id) external {
        crowdFund memory fund = funds[_id];
        require(block.timestamp > fund.closing, "not ended");
        require(fund.value < fund.goal, "You cannot Withdraw, Campaign has succeeded");

        uint bal = contributions[_id][msg.sender];
        contributions[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}
