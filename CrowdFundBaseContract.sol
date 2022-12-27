pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import "./CFToken.sol";
/*
This contract is generated using the Fundactory contract. This contract is not
upgradeable as the logic should not be changed to make the contract trustworthy. 
*/
contract Fund {
    //Below are the variables initialized during creation of the contract.
    uint256 key;
    uint goal;
    address beneficiary;
    bool isOver;
    uint opening;
    uint closing;
    uint value;
    uint public number;
    uint public duration;
    CFToken public token;

    //Below are the variables used to store state of the contract.
    bool cancelled;
    mapping(address => uint) public contributions;//contains all addressed and their contributions.


    event Cancel(uint256 indexed key);
    event Pledge(uint256 indexed key, address indexed caller, uint amount);
    event Claim(uint256 indexed key);
    event Refund(uint256 indexed key, address indexed caller, uint amount);

    error FundIsNotCancelled();
    error FundHasSucceeded();
    error FundHasNotEnded();

    /*
    This constructor is called from the FundFactory to initialize the smart contract.
    */
     constructor(address payable _token, uint _duration,uint _goal,
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
       /* require(cancelled == false, "This fund has been cancelled");
        require(block.timestamp >= opening, "Funding is yet to begin");
        require(block.timestamp <= closing, "Funding has ended");*/

        _;
    }

    modifier onlyValidClaim {
        require(value >= goal, "Campaign did not succed");
        require(!isOver, "claimed");

        _;
    }

    /*
    Cancels the funding. After calling this function pledging is no longer
    possible
    */
    function cancel() external onlyBeneficiary{
        cancelled=true;
        emit Cancel(key);
    }

    /*
    Users can transfer funds to the contract using this method.
    */
    function pledge(uint _amount) external onlyActiveFund  {
        value += _amount;
        contributions[msg.sender] += _amount;
        token.approve(address(this),_amount);
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledge(key, msg.sender, _amount);
    }

    /*
    Once the value is greater than the secified goal the beneficiary can
    claim the tokens using this method.
     */
    function claim() public onlyBeneficiary onlyValidClaim {
        isOver = true;
        token.transfer(beneficiary, value);
        emit Claim(number);
    }

    /*
    If the funds collected have not matched the goal in the secified
    duration the users can get their funds back.
    */
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

    /*
    This function is used to withdraw the tokens once the fund has been cancelled.
    */
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
