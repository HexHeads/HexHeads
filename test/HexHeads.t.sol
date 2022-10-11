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

    function testTokenURI() public {
        uint256 token = hexhead.originalTokenOf(0x3A205ECf286bBe11460638aCe47D501A53fB91C0);
        emit log_string(hexhead.tokenURI(token));
    }
}
