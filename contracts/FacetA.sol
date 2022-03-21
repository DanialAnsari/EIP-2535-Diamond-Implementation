
pragma solidity ^0.7.6;


contract FacetA {

   uint256 public age;  

  function setData(uint256 _age) external {
    age = _age;
  }

  function getData() external view returns (uint256) {
    return age;
  }
}