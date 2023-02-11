// SPDX-License-Identifier: MIT
/// @author k0rean_rand0m (https://twitter.com/k0rean_rand0m | https://github.com/k0rean-rand0m)
pragma solidity 0.8.17;

import "../libs/ERC1155.sol";
import "../libs/Owned.sol";
import "./Royalties.sol";

/////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                             //
//    ██╗  ██╗ ██╗  ██╗    ██╗   ██╗ ██████╗   ██████╗  ██████╗   █████╗  ██████╗  ███████╗    //
//    ██║  ██║ ██║  ██║    ██║   ██║ ██╔══██╗ ██╔════╝  ██╔══██╗ ██╔══██╗ ██╔══██╗ ██╔════╝    //
//    ███████║ ███████║    ██║   ██║ ██████╔╝ ██║  ███╗ ██████╔╝ ███████║ ██║  ██║ █████╗      //
//    ██╔══██║ ██╔══██║    ██║   ██║ ██╔═══╝  ██║   ██║ ██╔══██╗ ██╔══██║ ██║  ██║ ██╔══╝      //
//    ██║  ██║ ██║  ██║    ╚██████╔╝ ██║      ╚██████╔╝ ██║  ██║ ██║  ██║ ██████╔╝ ███████╗    //
//    ╚═╝  ╚═╝ ╚═╝  ╚═╝     ╚═════╝  ╚═╝       ╚═════╝  ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═════╝  ╚══════╝    //
//                                                                                             //
/////////////////////////////////////////////////////////////////////////////////////////////////

contract HexHeadsUpgrade is ERC1155, Owned, Royalties {

    uint256 public price = 0.0005 ether;
    uint256 public priceStep = 0.00001 ether;

    //// MUTABLES ////
    address public operator;
    string private _tokenURI;

    //// MODIFIERS ////
    modifier onlyOperator() {
        require(msg.sender == operator, "NOT_OPERATOR");
        _;
    }

    constructor(address _daoTreasury) Owned(msg.sender) Royalties(_daoTreasury) {}

    function uri(
        uint256 id
    ) public view override returns (string memory) {
        require(id == 1, "TOKEN_NOT_EXIST");
        return _tokenURI;
    }

    //// PUBLIC ////

    function mint(
        address to,
        uint256 amount
    ) external payable {
        require(amount > 0, "INVALID_AMOUNT");

        // Allows DAO to mint for free if needed
        if (msg.sender != owner) {
            require(msg.value >= price * amount, "INSUFFICIENT_ETH");
            price += priceStep;
        }
        Royalties._recalculate(msg.value);
        _mint(to, 1, amount, "");
    }

    function withdraw(
        bool _dao
    ) external {
        if (msg.sender == owner) {
            _withdraw(_dao);
        } else {
            _withdraw(false);
        }
    }

    /// ONLY OPERATOR ///

    function burn(
        address from,
        uint256 amount
    ) external onlyOperator {
        _burn(from, 1, amount);
    }

    /// ONLY OWNER ///

    function setDaoTreasury(
        address _treasury
    ) external onlyOwner {
        treasury = _treasury;
    }

    function setPrice(
        uint256 _price
    ) external onlyOwner {
        price = _price;
    }

    function setPriceStep(
        uint256 _priceStep
    ) external onlyOwner {
        priceStep = _priceStep;
    }

    function setURI(
        string calldata _uri
    ) external onlyOwner {
        _tokenURI = _uri;
    }

    function setOperator(
        address _operator
    ) external onlyOwner{
        operator = _operator;
    }

}
