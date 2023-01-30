pragma solidity ^0.8.0;

interface INameRegistry {
    function name(uint256 id) external view returns (string memory);
    function rename(uint256 id, string memory _name) external;
}
