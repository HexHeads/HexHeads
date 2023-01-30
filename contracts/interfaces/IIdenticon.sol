// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IIdenticon {
    function identicon(address user) external view returns (uint256 id);
    function setIdenticon(uint256 id) external;
}