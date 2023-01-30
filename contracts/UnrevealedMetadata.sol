pragma solidity ^0.8.0;

import "./interfaces/INameRegistry.sol";
import "./interfaces/IMetadata.sol";
import "./utils/Base64.sol";
import "./utils/Strings.sol";

contract UnrevealedMetadata is IMetadata {

    using Strings for uint256;

    //// STORAGE ////
    /// PUBLIC ///
    INameRegistry nameRegistry;

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
            ', "description": "An Unrevealed HexHead without a name"',
            ', "image": "https://hexheads.xyz/generator?id=', id.toString(), '"',
            ', "attributes": [{"trait_type": "Name", "value": "', name, '"}, ',
                               '{"trait_type": "Prime Level", "value": "', primeLevel.toString(), '"}]'
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
