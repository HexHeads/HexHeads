pragma solidity 0.8.17;

import "./interfaces/IIdenticon.sol";
import "../libs/Owned.sol";

contract IdenticonRegistry is IIdenticon, Owned {

    address public operator;
    mapping(address => uint256) public identicons;

    constructor() Owned(msg.sender){}

    modifier onlyOperator() {
        require(msg.sender == operator, "NOT_OPERATOR");
        _;
    }

    //// PUBLIC ////

    function identicon(
        address user
    ) public view returns (uint256 id) {
        return identicons[user];
    }

    //// ONLY OPERATOR ////

    function setIdenticon(
        address user,
        uint256 id
    ) public onlyOperator {
        identicons[user] = id;
    }

    //// ONLY OWNER ////

    function setOperator(
        address _operator
    ) external onlyOwner{
        operator = _operator;
    }
}
