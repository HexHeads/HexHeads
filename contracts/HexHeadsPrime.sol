// SPDX-License-Identifier: MIT
/// @author k0rean_rand0m (https://twitter.com/k0rean_rand0m | https://github.com/k0rean-rand0m)
pragma solidity 0.8.17;

import "./interfaces/IMetadata.sol";
import "./interfaces/IHexHeadsPrime.sol";
import "../libs/ERC721.sol";
import "../libs/Owned.sol";

///////////////////////////////////////////////////////////////////////////
//                                                                       //
//    ██╗  ██╗ ██╗  ██╗    ██████╗  ██████╗  ██╗ ███╗   ███╗ ███████╗    //
//    ██║  ██║ ██║  ██║    ██╔══██╗ ██╔══██╗ ██║ ████╗ ████║ ██╔════╝    //
//    ███████║ ███████║    ██████╔╝ ██████╔╝ ██║ ██╔████╔██║ █████╗      //
//    ██╔══██║ ██╔══██║    ██╔═══╝  ██╔══██╗ ██║ ██║╚██╔╝██║ ██╔══╝      //
//    ██║  ██║ ██║  ██║    ██║      ██║  ██║ ██║ ██║ ╚═╝ ██║ ███████╗    //
//    ╚═╝  ╚═╝ ╚═╝  ╚═╝    ╚═╝      ╚═╝  ╚═╝ ╚═╝ ╚═╝     ╚═╝ ╚══════╝    //
//                                                                       //
///////////////////////////////////////////////////////////////////////////

contract HexHeadsPrime is ERC721, Owned {

    //// STORAGE ////

    // CONSTANTS //
    uint256 constant public maxSupply = 1461501637330902918203684832716283019655932542975;

    // MUTABLES //
    address public operator;
    mapping(uint256 => uint256) public primeLevel;
    uint256 public primeLevelsAccumulated = 0;
    IMetadata public metadataProvider;

    //// MODIFIERS ////
    modifier onlyOperator() {
        require(msg.sender == operator, "NOT_OPERATOR");
        _;
    }

    //// CONSTRUCTOR ////
    constructor(
        IMetadata _metadataProvider
    ) ERC721("HexHeads", "HEX") Owned(msg.sender) {
        metadataProvider = _metadataProvider;
    }

    //// PUBLIC ////

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return
        interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
        interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
        interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    function tokenURI(
        uint256 id
    ) public view override returns (string memory) {
        require(id <= maxSupply, "INVALID_ID");
        return metadataProvider.tokenURI(id, primeLevel[id]);
    }

    /// ONLY OPERATOR ///

    function mint(
        address to,
        uint256 id,
        uint256 level
    ) external onlyOperator {
        primeLevel[id] += level;
        primeLevelsAccumulated += level;

        _mint(to, id);
    }

    function upgrade(
        uint256 id,
        uint256 level
    ) external onlyOperator {
        primeLevel[id] += level;
        primeLevelsAccumulated += level;
    }

    /// ONLY OWNER ///

    function setMetadataProvider(
        IMetadata _metadataProvider
    ) external onlyOwner {
        metadataProvider = _metadataProvider;
    }

    function setOperator(
        address _operator
    ) external onlyOwner{
        operator = _operator;
    }
}
