pragma solidity ^0.8.0;

import "./interfaces/INameRegistry.sol";
import "./interfaces/IERC721.sol";

contract NameRegistry {

    //// STORAGE ////
    /// PUBLIC ///
    mapping(uint256 => string) private _name;
    mapping(string => bool) public claimed;
    IERC721 public hexHeads;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function name(uint256 id) external view returns (string memory) {
        string memory name_ = _name[id];
        if (bytes(name_).length == 0) {
            return "HexHead";
        }
        return name_;
    }

    function rename(
        uint256 id,
        string memory name_
    ) external {
        require(msg.sender == address(hexHeads) || msg.sender == hexHeads.ownerOf(id), "NOT_THE_OWNER_OF_HEXHEAD");
        require(keccak256(abi.encodePacked(name_)) != keccak256(abi.encodePacked("HexHead")), "NAME_IS_NOT_AVAILABLE");
        // TODO name length
        if(bytes(name_).length != 0) {
            require(!claimed[name_], "NAME_IS_ALREADY_CLAIMED");
            claimed[name_] = true;
        }

        _name[id] = name_;
    }

    function setHexHeads(IERC721 hh) external {
        require(msg.sender == owner, "NOT_AUTHORIZED");
        owner = address(0);
        hexHeads = hh;
    }

}
