pragma solidity 0.8.17;

import "./interfaces/IHexHeads.sol";
import "./interfaces/IHexHeadsPrime.sol";
import "./interfaces/IHexHeadsUpgrade.sol";
import "./interfaces/INameRegistry.sol";
import "./interfaces/IIdenticon.sol";
import "../libs/Owned.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                      //
//    ██╗  ██╗ ██╗  ██╗     ██████╗  ██████╗  ███████╗ ██████╗   █████╗  ████████╗  ██████╗  ██████╗    //
//    ██║  ██║ ██║  ██║    ██╔═══██╗ ██╔══██╗ ██╔════╝ ██╔══██╗ ██╔══██╗ ╚══██╔══╝ ██╔═══██╗ ██╔══██╗   //
//    ███████║ ███████║    ██║   ██║ ██████╔╝ █████╗   ██████╔╝ ███████║    ██║    ██║   ██║ ██████╔╝   //
//    ██╔══██║ ██╔══██║    ██║   ██║ ██╔═══╝  ██╔══╝   ██╔══██╗ ██╔══██║    ██║    ██║   ██║ ██╔══██╗   //
//    ██║  ██║ ██║  ██║    ╚██████╔╝ ██║      ███████╗ ██║  ██║ ██║  ██║    ██║    ╚██████╔╝ ██║  ██║   //
//    ╚═╝  ╚═╝ ╚═╝  ╚═╝     ╚═════╝  ╚═╝      ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝    ╚═╝     ╚═════╝  ╚═╝  ╚═╝   //
//                                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////

contract HexHeadsOperator is Owned {
    //// STORAGE ////

    //// IMMUTABLE ////
    IHexHeads public immutable hexHeads;
    IHexHeadsPrime public immutable hexHeadsPrime;
    IHexHeadsUpgrade public immutable hexHeadsUpgrade;
    INameRegistry immutable public nameRegistry;
    IIdenticon immutable public identiconRegistry;

    //// MUTABLE ////
    uint256 public foilMintLevel;

    //// CONSTRUCTOR ////
    constructor(
        IHexHeads _hexHeads,
        IHexHeadsPrime _hexHeadsPrime,
        IHexHeadsUpgrade _hexHeadsUpgrade,
        INameRegistry _nameRegistry,
        IIdenticon _identiconRegistry
    ) Owned(msg.sender) {
        hexHeads = _hexHeads;
        hexHeadsPrime = _hexHeadsPrime;
        hexHeadsUpgrade = _hexHeadsUpgrade;
        nameRegistry = _nameRegistry;
        identiconRegistry = _identiconRegistry;
        foilMintLevel = 1;
    }

    //// PUBLIC ////
    function mint(
        string memory name
    ) external {
        uint256 id = _addressToId(msg.sender);
        if (_isFoil(id)) {
            hexHeadsPrime.mint(msg.sender, id, foilMintLevel);
        } else {
            hexHeads.mint(msg.sender, id);
        }
        nameRegistry.rename(id, name);
    }

    function upgrade(
        uint256 id,
        uint256 level
    ) external {

        hexHeadsUpgrade.burn(msg.sender, level);
        if(hexHeadsPrime.ownerOf(id) == msg.sender) {
            hexHeadsPrime.upgrade(id, level);
        } else {
            hexHeads.burn(msg.sender, id);
            hexHeadsPrime.mint(msg.sender, id, level);
        }
    }

    function rename(
        uint256 id,
        string calldata name
    ) external {
        if(hexHeads.ownerOf(id) == msg.sender || hexHeadsPrime.ownerOf(id) == msg.sender) {
            nameRegistry.rename(id, name);
        }
    }

    /// IDENTICON ///

    // Proxy-function to identiconRegistry
    function identicon(
        address user
    ) external view returns (uint256 id) {
        return identiconRegistry.identicon(user);
    }

    function setIdenticon(
        uint256 id
    ) external {
        require(
            hexHeadsPrime.ownerOf(id) == msg.sender ||
            hexHeads.ownerOf(id) == msg.sender,
            "NOT_AUTHORIZED"
        );

        identiconRegistry.setIdenticon(msg.sender, id);
    }

    //// ONLY OWNER ////
    function setFoilMintLevel(
        uint256 level
    ) external onlyOwner {
        foilMintLevel = level;
    }

    //// PRIVATE ////
    function _isFoil(
        uint256 id
    ) private returns (bool) {
        return false; // TODO implement
    }

    function _addressToId(
        address who
    ) private pure returns (uint256 id) {
        return uint256(bytes32(bytes20(who)) >> 96);
    }
}
