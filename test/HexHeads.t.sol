// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/HexHeads.sol";

contract AvatarTest is Test {
    HexHeads public hexhead;

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    function setUp() public {
        hexhead = new HexHeads();
    }

    function testMinted() public {
        uint256 token = hexhead.originalTokenOf(address(this));
        assertEq(hexhead.minted(token), false);
        hexhead.mint(address(this));
        assertEq(hexhead.minted(token), true);
    }

    function testAutomint() public {
        emit log_uint(hexhead.originalTokenOf(0x78993A1825B323C0De7503f692f21B63808219DB));
        uint256 token = hexhead.originalTokenOf(address(this));
        assertEq(hexhead.minted(token), false);
        hexhead.transferFrom(address(this), 0x78993A1825B323C0De7503f692f21B63808219DB, token);
        assertEq(hexhead.minted(token), true);
    }

    function testTransfer() public {
        uint256 token = hexhead.originalTokenOf(address(this));
        assertEq(hexhead.minted(token), false);
        hexhead.mint(address(this));
        assertEq(hexhead.minted(token), true);
        assertEq(hexhead.ownerOf(token), address(this));
        hexhead.transferFrom(address(this), 0x78993A1825B323C0De7503f692f21B63808219DB, token);
        assertEq(hexhead.ownerOf(token), 0x78993A1825B323C0De7503f692f21B63808219DB);
    }

    function toColor(bytes32 value) internal pure returns (string memory) {
        uint256 num = uint256(value);
        bytes memory buffer = new bytes(8);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 7; i > 1; --i) {
            buffer[i] = _SYMBOLS[num & 0xf];
            num >>= 4;
        }
        require(num == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function testTokenURI() public {
        uint256 token = hexhead.originalTokenOf(0x3A205ECf286bBe11460638aCe47D501A53fB91C0);
        emit log_string(hexhead.tokenURI(token));
    }

//    function testTokenTraits() public {
//        uint256 token = hexhead.originalTokenOf(0x3A205ECf286bBe11460638aCe47D501A53fB91C0);
//        hexhead.tokenTraits(token);
//    }

    event log_bytes20 (
        bytes20 data
    );

//    function testAddressToTrait() public {
//
//        bytes32 buffer = bytes32(bytes20(0x6D676Aa717f347eB6809074Ee77BA50CE3A09A5E));
//        uint256 displacement = uint256(buffer << 144 >> 240);
//
//        uint256[6] memory traits;
//
//        for (uint256 i = 0; i <= 5; i++) {
//            if (i == 0) {
//                traits[i] = (uint256(buffer << (24 + 20*i) >> 236) + displacement) % 10;
//            } else if (i == 2) {
//                traits[i] = (uint256(buffer << (24 + 20*i) >> 236) + displacement) % 12;
//            } else {
//                traits[i] = (uint256(buffer << (24 + 20*i) >> 236) + displacement) % 30;
//            }
//        }
//
//        for (uint256 i = 0; i <= 5; i++) {
//            emit log_uint(traits[i]);
//        }
//    }
}
