// SPDX-License-Identifier: MIT
/// @author k0rean_rand0m (https://twitter.com/k0rean_rand0m | https://github.com/k0rean-rand0m)
pragma solidity 0.8.17;

import "./interfaces/IIdenticon.sol";
import "./interfaces/IERC721.sol";
import "./interfaces/IMetadata.sol";
import "./interfaces/INameRegistry.sol";
import "../libs/ERC721.sol";
import "../libs/Owned.sol";
import "./Royalties.sol";

///////////////////////////////////////////////////////////////////////////////////
//                                                                               //
//    ██╗  ██╗ ███████╗ ██╗  ██╗ ██╗  ██╗ ███████╗  █████╗  ██████╗  ███████╗    //
//    ██║  ██║ ██╔════╝ ╚██╗██╔╝ ██║  ██║ ██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝    //
//    ███████║ █████╗    ╚███╔╝  ███████║ █████╗   ███████║ ██║  ██║ ███████╗    //
//    ██╔══██║ ██╔══╝    ██╔██╗  ██╔══██║ ██╔══╝   ██╔══██║ ██║  ██║ ╚════██║    //
//    ██║  ██║ ███████╗ ██╔╝ ██╗ ██║  ██║ ███████╗ ██║  ██║ ██████╔╝ ███████║    //
//    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══════╝    //
//                                                                               //
///////////////////////////////////////////////////////////////////////////////////

contract HexHeads is ERC721, IIdenticon, Owned, Royalties {

    //// STORAGE ////
    /// PUBLIC ///

    // CONSTANTS //
    uint256 constant public maxSupply = 1461501637330902918203684832716283019655932542975;

    // IDENTICON MUTABLES //
    mapping(address => uint256) public identicon;

    // PRIME MUTABLES //
    uint256 public primeTotal = 0;

    mapping(uint256 => uint256) public primeLevel;
    uint256 public primeLevelsAccumulated = 0;

    uint256 public primeLevelPrice = 0.001 ether;
    uint256 public primeLevelPriceStep = 0.001 ether;

    // MINTING MUTABLES //
    uint256 public mintedTotal;

    // METADATA MUTABLES //
    IMetadata metadataProvider;
    INameRegistry nameRegistry;

    //// CONSTRUCTOR ////
    constructor(
        INameRegistry _nameRegistry,
        IMetadata _metadataProvider,
        address _daoTreasury
    ) ERC721("HexHeads", "HEX") Owned(msg.sender) Royalties(_daoTreasury) {
        metadataProvider = _metadataProvider;
        nameRegistry = _nameRegistry;
    }

    //// PUBLIC ////

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return
        interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
        interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
        interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(id <= maxSupply, "INVALID_ID");
        return metadataProvider.tokenURI(id, primeLevel[id]);
    }

    function mint(uint256 levels, string memory name) external payable {
        require(msg.value >= primeLevelPrice * levels, "INSUFFICIENT_ETH");

        // Royalties
        if (msg.value > 0) {
            _recalculate(msg.value);
        }

        uint256 id = _addressToId(msg.sender);

        // Prime management
        if (levels > 0) {
            primeTotal += 1;
            primeLevel[id] += levels;
            primeLevelsAccumulated += levels;
            primeLevelPrice += primeLevelPriceStep;
        }
        mintedTotal += 1;

        _mint(msg.sender, id);
        nameRegistry.rename(id, name);
    }

    function setIdenticon(uint256 id) external {
        require(msg.sender == ownerOf(id), "NOT_THE_OWNER");
        identicon[msg.sender] = id;
    }

    function withdraw(bool _dao) external {
        if (msg.sender == owner) {
            _withdraw(_dao);
        } else {
            _withdraw(false);
        }
    }

    /// ONLY OWNER ///
    function setDaoTreasury(
        address _treasury
    ) external onlyOwner {
        treasury = _treasury;
    }

    function setMetadataProvider(
        IMetadata _metadataProvider
    ) external onlyOwner {
        metadataProvider = _metadataProvider;
    }

    function setPrimeLevelPrice(
        uint256 _primeLevelPrice
    ) external onlyOwner {
        primeLevelPrice = _primeLevelPrice;
    }

    function setPrimeLevelPriceStep(
        uint256 _primeLevelPriceStep
    ) external onlyOwner {
        primeLevelPriceStep = _primeLevelPriceStep;
    }

    function setPrimeLevel(
        uint256 id,
        uint256 level
    ) external onlyOwner {
        uint256 currentLevel = primeLevel[id];
        require(currentLevel < level, "CANT_DECREASE_LEVEL");
        primeLevel[id] = level;
    }

    //// PRIVATE ////
    function _minted(uint256 id) private view returns (bool) {
        return _ownerOf[id] != address(0);
    }

    function _addressToId(address who) private pure returns (uint256 id) {
        return uint256(bytes32(bytes20(who)) >> 96);
    }

}
