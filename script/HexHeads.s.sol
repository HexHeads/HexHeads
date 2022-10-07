// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/HexHeads.sol";

contract AvatarDeploy is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        new HexHeads();

        vm.stopBroadcast();
    }
}
