pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import "./CFToken.sol";
contract Fund is ReentrancyGuardUpgradeable{
    
    string key;
    uint goal;
    address beneficiary;
    bool isOver;
    uint opening;
    uint closing;
    uint value;
    

    
    bool cancelled;
    uint public number;
    CFToken public token;
    uint public duration;
    mapping(address => uint) public contributions;

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

     function initialize(address payable _token, uint _duration,uint _goal,
     address _beneficiary,uint _opening,uint _closing,uint _value) 
  public     {
      token = CFToken(_token);
      duration=_duration;
     goal=_goal;
     beneficiary=_beneficiary;
     opening=_opening;
     closing=_closing;
     value=_value;
  }

  

    function cancel(uint _id) external {
        require(beneficiary == msg.sender, "You did not create this Campaign");
        require(block.timestamp < opening, "Campaign has already started");

        cancelled=true;
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        require(block.timestamp >= opening, "Campaign has not Started yet");
        require(block.timestamp <= closing, "Campaign has already ended");
        value += _amount;
        contributions[msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unPledge(uint _id,uint _amount) external {
        require(block.timestamp >= opening, "Campaign has not Started yet");
        require(block.timestamp <= closing, "Campaign has already ended");
        require(contributions[msg.sender] >= _amount,"You do not have enough tokens Pledged to withraw");

        value -= _amount;
        contributions[msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        require(beneficiary == msg.sender, "You did not create this Campaign");
        require(block.timestamp > closing, "Campaign has not ended");
        require(value >= goal, "Campaign did not succed");
        require(!isOver, "claimed");

        isOver = true;
        token.transfer(beneficiary, value);

        emit Claim(_id);
    }

    function refund(uint _id) external {
        require(block.timestamp > closing, "not ended");
        require(value < goal, "You cannot Withdraw, Campaign has succeeded");

        uint bal = contributions[msg.sender];
        contributions[msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}
