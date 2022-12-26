pragma solidity ^0.8.0;
import "./CrowdFundBaseContract.sol";
import "./CFToken.sol";
contract Factory {
  event Deployed(address addr);
  address public dep;
  function deploy(address tokenAddress) public returns(address) {
        CrowdFundBaseContract c=new CrowdFundBaseContract(6,tokenAddress); 
        address newProjectAddress = address(c); // here
        CFToken(tokenAddress).addContract(newProjectAddress);
        dep=newProjectAddress;
  }
}
