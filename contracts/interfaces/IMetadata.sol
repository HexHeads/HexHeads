pragma solidity ^0.8.0;

interface IMetadata {
    function tokenURI(uint256, uint256) external view virtual returns (string memory);
}
