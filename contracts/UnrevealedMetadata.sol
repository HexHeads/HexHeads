pragma solidity ^0.8.0;

import "./interfaces/INameRegistry.sol";
import "./interfaces/IMetadata.sol";
import "./utils/Base64.sol";
import "./utils/Strings.sol";

contract UnrevealedMetadata is IMetadata {

    using Strings for uint256;

    //// STORAGE ////

    /// PUBLIC IMMUTABLE ///
    INameRegistry immutable public nameRegistry;

    //// CONSTRUCTOR ////
    constructor(INameRegistry _nameRegistry) {
        nameRegistry = _nameRegistry;
    }

    function tokenURI(
        uint256 id,
        uint256 primeLevel
    ) public view returns (string memory) {

        string memory name = nameRegistry.name(id);

        bytes memory dataURI = abi.encodePacked(
            '{',
            '"name": "', name, '"',
            ', "external_url": "https://hexheads.xyz"',
            ', "description": "An Unrevealed HexHead"',
            ', "image": "https://raw.githubusercontent.com/k0rean-rand0m/img/main/question.png"',
            ', "attributes": [{"trait_type": "Name", "value": "', name, '"}]',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

}
