pragma solidity ^0.8.0;

interface IHexHeadsPrime {

    function mint(
        address to,
        uint256 id,
        uint256 level
    ) external;

    function upgrade(
        uint256 id,
        uint256 level
    ) external;

    function ownerOf(
        uint256 id
    ) external view returns (address);
}
