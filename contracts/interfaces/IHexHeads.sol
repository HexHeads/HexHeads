pragma solidity ^0.8.0;

interface IHexHeads {

    function mint(
        address to,
        uint256 id
    ) external;

    function burn(
        address from,
        uint256 id
    ) external;

    function ownerOf(
        uint256 id
    ) external view returns (address);

}
