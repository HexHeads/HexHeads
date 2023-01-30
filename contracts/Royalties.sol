pragma solidity ^0.8.0;

contract Royalties {

    //// STORAGE ////
    /// PUBLIC ///

    // Initial team royalties //
    uint256 public teamShareDivider = 2; // 0.5
    mapping(address => uint256) public teamClaimable;
    uint256 public teamTotalClaimable;

    // DAO Treasury //
    address public treasury;

    //// CONSTRUCTOR ////
    constructor(address _daoTreasury) {
        treasury = _daoTreasury;
    }

    //// INTERNAL ////
    function _withdraw(bool dao) internal {
        uint256 amount;
        address recipient = msg.sender;
        if (dao) {  // DAO withdrawal
            recipient = treasury;
            amount = address(this).balance - teamTotalClaimable;
        } else {
            amount = teamClaimable[recipient];
            teamClaimable[recipient] = 0;
            teamTotalClaimable -= amount;
        }
        (bool sent,) = recipient.call{value: amount}("");
        require(sent, "WITHDRAW_ERROR");
    }

    function _recalculate(uint256 value) internal {
        // Calculate team royalties
        uint256 teamShare = 0;
        if (teamShareDivider != 0) {
            teamShare = value/teamShareDivider;
            teamTotalClaimable += teamShare*20/100 + teamShare*15/100 + teamShare*25/100 + teamShare*40/100;
            // Distribute team royalties
            // TODO int division might cause errors
            // Artist
            teamClaimable[0x990050d60F99C23C8E546856955fba5cDd5844dB] += teamShare * 20/100;
            // UI dev
            teamClaimable[0xA105440e9B0C5A5420954746A9d98c9F7C6580F8] += teamShare * 15/100;
            // Marketing
            teamClaimable[0x7C0654A3Bb1d2783aA68E4D05310c13683dd30c5] += teamShare * 25/100;
            // HH contracts / DAO dev
            teamClaimable[0x3A205ECf286bBe11460638aCe47D501A53fB91C0] += teamShare * 40/100;
        }
    }

}
