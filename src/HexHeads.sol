// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IERC721E.sol";
import "./interfaces/IERC721.sol";
import "./utils/Base64.sol";
import "./utils/Strings.sol";

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//    ██╗  ██╗███████╗██╗  ██╗██╗  ██╗███████╗ █████╗ ██████╗ ███████╗    //
//    ██║  ██║██╔════╝╚██╗██╔╝██║  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝    //
//    ███████║█████╗   ╚███╔╝ ███████║█████╗  ███████║██║  ██║███████╗    //
//    ██╔══██║██╔══╝   ██╔██╗ ██╔══██║██╔══╝  ██╔══██║██║  ██║╚════██║    //
//    ██║  ██║███████╗██╔╝ ██╗██║  ██║███████╗██║  ██║██████╔╝███████║    //
//    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝    //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

/// @notice An ERC-721 implementation with an NFT linked with every wallet by default
/// @author k0rean_rand0m (https://twitter.com/k0rean_rand0m | https://github.com/k0rean-rand0m)
contract HexHeads is IERC721E, IERC721  {

    using Strings for uint256;
    using Strings for address;

    //// STORAGE ////

    /// PUBLIC ///

    // CONSTANTS //
    uint256 constant public maxSupply = 1461501637330902918203684832716283019655932542975;
    string constant public name = "HexHeads";
    string constant public symbol = "HEX";

    // MUTABLES //
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /// PRIVATE ///

    // CONSTANTS //
    string[][6] private _traits;

    // MUTABLES //
    mapping(uint256 => address) private _ownerOf;
    mapping(address => uint256) private _balanceOf;
    mapping(uint256 => bool) public minted;
    bool public transferable = true;

    //// CONSTRUCTOR ////

    constructor() {
        _traits[0] = ["Sky", "Desert", "Field", "Syringa", "Deep Space", "Star", "Pool", "Ocean", "Fog", "Bubble Gum"];
        _traits[1] = ["", "Snowball", "Circles", "+", "|", "-", "*", "Dirty", "Dimmed", "Chess Lover", "Linear", "Radial", "/", "Beer Lover", "Matrix", "Shadow", "Field", "Open Sea", "Eclipse", "Half-Full", "Labyrinths", "Bees", "Peace", "Mess", "Aquarium", "Basketball", "Star", "Hazard", "Road", "Collectible"];
        _traits[2] = ["Human", "Human", "Human", "Human", "Alien | Moon", "Alien | Venus", "Alien | Mars", "Daemon", "Angel", "Anon", "Starborn", "Weird One"];
        _traits[3] = ["Bold", "Regular Haircut", "Regular Haircut", "Regular Haircut", "Regular Haircut", "Regular Haircut", "Warm Hat", "Halo", "Wires", "Horns", "Farmer", "Ninja", "Plastic Bag", "Science Fiction", "Nimbus", "Poseidon Crown", "Launchpad", "Crash", "Flower", "Rainy", "Regular Haircut", "Regular Haircut", "Regular Haircut", "Regular Haircut", "Regular Haircut", "Transmitter", "Foil Hat", "S.W.A.T. Hat", "Bear Market", "Into the Metaverse"];
        _traits[4] = ["Regular", "LOL", "| |", "- -", "Pretty shocked", "Geek Glasses", "3D", "Cool Glasses", "Elite", "+ +", "T T", "Eyelashes", "\\ /", "/ \\", "Beach Party", "Take a look", "Why pink?!", "Spider", "Tears", "Observing", "Suspicious", "Zombie", "Extra Eye", "Pleasure", "Rich Nerd", "Nerd Sunglasses", "Ninja", "Night Vision", "Displaced", "Meta Headset", ""];
        _traits[5] = ["Ok", "M?", "Hmm", "Aww", "Yum", "Meh", "Mustache", "M-m?", "Yay", "S-s-s", "...", "Red Lips", "Pop", "Ueee", "Hipster Mustache", "Talking", "Sweet-tooth", "Smoker", "Ice Cream Lover", "Woah!", "Tiny Mustache", "Pro Hipster", "Wise", "Beardie", "Oops", "Vampire", "Ninja Mask", "Gas Mask", "Pure Gold", "Sharp Teeth"];
    }

    //// IERC721E IMPLEMENTATION ////

    function originalTokenOf(address originalOwner) public pure virtual returns (uint256 id) {
        return uint256(bytes32(bytes20(originalOwner)) >> 96);
    }

    function originalOwnerOf(uint256 id) public view virtual returns (address originalOwner) {
        require(id <= maxSupply, "NOT_EXISTS");
        return address(bytes20(bytes32(id) << 96));
    }

    //// IERC721 IMPLEMENTATION ////

    event ETrait (
      uint256 trait_id
    );

    function tokenURI(uint256 id) public view virtual returns (string memory) {

        address originalOwner = originalOwnerOf(id);
        uint256[6] memory traits = _addressToTraits(originalOwner);

        bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "HexHead #', id.toString(), '",',
            '"external_url": "https://hexheads.xyz",',
            '"description": "A token you already own",',
            '"animation_url": "https://hexheads.xyz/image.html?address=', originalOwner.toHexString(), '",',
            '"attributes": [',
                '{"trait_type": "Background",',
                '"value": "', uint256(uint160(bytes20(0x3A205ECf286bBe11460638aCe47D501A53fB91C0) >> 136)).toColor(),'"},',
                '{"trait_type": "Bubble Color",',
                '"value": "', _traits[0][traits[0]],'"},',
                '{"trait_type": "Bubble",',
                '"value": "', _traits[1][traits[1]],'"},',
                '{"trait_type": "Head",',
                '"value": "', _traits[2][traits[2]],'"},',
                '{"trait_type": "Accessory",',
                '"value": "', _traits[3][traits[3]],'"},',
                '{"trait_type": "Eyes",',
                '"value": "', _traits[4][traits[4]],'"},',
                '{"trait_type": "Mouth",',
                '"value": "', _traits[5][traits[5]],'"}',
            ']',
        '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require(id <= maxSupply, "NOT_EXISTS");

        owner = _ownerOf[id];
        if (owner == address(0) && !minted[id]) {
            return originalOwnerOf(id);
        }
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        uint256 balance = _balanceOf[owner];
        if (!minted[originalTokenOf(owner)]) {
            balance += 1;
        }
        return balance;
    }

    function approve(address spender, uint256 id) public virtual {
        address owner = ownerOf(id);
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;
        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(transferable, "NOT_TRANSFERABLE");
        require(from == ownerOf(id), "WRONG_FROM");
        require(to != address(0), "INVALID_RECIPIENT");
        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        if (!minted[id]) _mint(originalOwnerOf(id), id);

        unchecked {
            _balanceOf[from]--;
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;
        delete getApproved[id];
        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == type(IERC721E).interfaceId ||
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata;
    }

    //// PUBLIC ////
    function mint(address to) external {
        uint256 id = originalTokenOf(to);
        _mint(to, id);
    }

    //// INTERNALS ////

    function _addressToTraits(address addr) internal pure returns(uint256[6] memory) {
        bytes32 buffer = bytes32(bytes20(addr));
        uint256 displacement = uint256(buffer << 144 >> 240);

        uint256[6] memory traits;

        for (uint256 i = 0; i <= 5; i++) {
            if (i == 0) {
                traits[i] = (uint256(buffer << (24 + 20*i) >> 236) + displacement) % 10;
            } else if (i == 2) {
                traits[i] = (uint256(buffer << (24 + 20*i) >> 236) + displacement) % 12;
            } else {
                traits[i] = (uint256(buffer << (24 + 20*i) >> 236) + displacement) % 30;
            }
        }

        return traits;
    }

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");
        require(!minted[id], "ALREADY_MINTED");

        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;
        minted[id] = true;
        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];
        require(owner != address(0), "NOT_MINTED");

        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];
        delete getApproved[id];
        emit Transfer(owner, address(0), id);
    }

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}