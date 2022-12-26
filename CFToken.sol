pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract CFToken is ERC20{
     
     address owner;
     address factory;
     mapping(address=>uint256) crowdFundContracts;
     
     constructor(uint256 totalSupply,address _factory) ERC20("CFToken","CF"){
         owner=msg.sender;
         factory=_factory;
        _mint(owner, totalSupply);
     }

     modifier onlyFactory {
        require(msg.sender == factory, "Only the assigned CF Token can perform this action");
        _;
    }


     function addContract(address fundContract) public onlyFactory {
        crowdFundContracts[fundContract]=0;
     }




}
