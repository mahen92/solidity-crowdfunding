pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import "./CFToken.sol";
contract Fund is ReentrancyGuardUpgradeable{
    
    uint256 key;
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


    event Cancel(uint256 indexed key);
    event Pledge(uint256 indexed key, address indexed caller, uint amount);
    event Unpledge(uint256 indexed key, address indexed caller, uint amount);
    event Claim(uint256 indexed key);
    event Refund(uint256 indexed key, address indexed caller, uint amount);

    error FundIsNotCancelled();
    error FundHasSucceeded();
    error FundHasNotEnded();

     function initialize(address payable _token, uint _duration,uint _goal,
     address _beneficiary,uint _opening,uint _closing,uint _value,uint256 _number) 
  public     {
     token = CFToken(_token);
     duration=_duration;
     goal=_goal;
     beneficiary=_beneficiary;
     opening=_opening;
     closing=_closing;
     value=_value;
     key=number;
  }

     modifier onlyBeneficiary {
        require(msg.sender == beneficiary, "Only the beneficiary can perform this action.");
        _;
    }

    modifier onlyActiveFund {
        require(cancelled == false, "This fund has been cancelled");
        require(block.timestamp >= opening, "Funding is yet to begin");
        require(block.timestamp <= closing, "Funding has ended");

        _;
    }

    modifier onlyValidClaim {
        require(value >= goal, "Campaign did not succed");
        require(!isOver, "claimed");

        _;
    }

    function cancel() external onlyBeneficiary{
        cancelled=true;
        emit Cancel(key);
    }

    function pledge(uint _amount) external onlyActiveFund  {
        value += _amount;
        contributions[msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(key, msg.sender, _amount);
    }

    function claim() public onlyBeneficiary onlyValidClaim {

        isOver = true;
        token.transfer(beneficiary, value);

        emit Claim(number);
    }

    function refund() external  {
        if(value>goal)
        {
          revert FundHasSucceeded();
        }
        if(block.timestamp <= closing)
        {
         revert FundHasNotEnded();
        }

        uint bal = contributions[msg.sender];
        contributions[msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(key,msg.sender, bal);
    }

    function withdraw() external {
        if(cancelled!=true)
        {
        revert FundIsNotCancelled();
        }
        uint bal = contributions[msg.sender];
        contributions[msg.sender] = 0;
        token.transfer(msg.sender, bal);
    }
}
