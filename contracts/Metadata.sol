pragma solidity ^0.8.0;

import "./utils/Base64.sol";
import "./utils/Strings.sol";

contract Metadata {

    using Strings for uint256;

    //// CONSTANTS ////

    string[10] private _layerLabels;
    string[][10] private _traits;

    //// CONSTRUCTOR ////

    constructor() {
        _layerLabels[0] = "Background";
        _layerLabels[1] = "Decoration";
        _layerLabels[2] = "Decoration Color";
        _layerLabels[3] = "Head";
        _layerLabels[4] = "Mouth";
        _layerLabels[5] = "Eyes";
        _layerLabels[6] = "Hair";
        _layerLabels[7] = "Hat";
        _layerLabels[8] = "Accessory";
        _layerLabels[9] = "Extra";

        _traits[0] = ["Blue", "Green", "Purple", "Red", "Yellow"];
        _traits[1] = ["Bubbles", "Circles", "Dots", "Lines", "Squares"];
        _traits[2] = ["Blue", "Green", "Purple", "Red", "Yellow"];
        _traits[3] = ["Alien", "Bunny", "Cat", "Dog", "Human"];
        _traits[4] = ["Angry", "Happy", "Sad", "Serious", "Smile"];
        _traits[5] = ["Angry", "Happy", "Sad", "Serious", "Smile"];
        _traits[6] = ["Bald", "Bun", "Long", "Short", "Spiky"];
        _traits[7] = ["Beanie", "Cowboy", "Fedora", "Top", "Wizard"];
        _traits[8] = ["Glasses", "Mask", "Mustache", "Necklace", "None"];
        _traits[9] = ["Crown", "Earrings", "Glasses", "Mask", "None"];
    }

    function tokenURI(
        uint256 id
    ) public view returns (string memory) {
        return "";
    }

//    function tokenURI(
//        address claimer
//    ) public view returns (string memory) {
//
//        return "";
//        uint256[6] memory traits = _addressToTraits(originalOwner);
//        bool foil = (id % 1611709650000001) == 0;
//
//        bytes memory dataURI = abi.encodePacked(
//            '{',
//            '"name": "HexHead #', id.toString(), '",',
//            '"external_url": "https://hexheads.xyz",',
//            '"description": "A token you already own",',
//            '"animation_url": "https://hexheads.xyz/image.html?address=', originalOwner.toHexString(), '",',
//            '"attributes": ['
//        );
//
//        if (foil) {
//            dataURI = abi.encodePacked(dataURI,
//                '{"trait_type": "Background",',
//                '"value": "Foil"},'
//                '{"trait_type": "Bubble Color",',
//                '"value": "Foil"},'
//                '{"trait_type": "Role",',
//                '"value": "Prime"},'
//            );
//        } else {
//            string memory role;
//            if (prime[id]) {
//                role = "Prime";
//            } else {
//                role = "Observer";
//            }
//            dataURI = abi.encodePacked(dataURI,
//                '{"trait_type": "Background",',
//                '"value": "', uint256(uint160(bytes20(originalOwner) >> 136)).toColor(),'"},'
//                '{"trait_type": "', _layerLabels[0], '",',
//                '"value": "', _traits[0][traits[0]], '"},'
//                '{"trait_type": "Role",',
//                '"value": "', role, '"},'
//            );
//        }
//
//        for (uint256 i = 1; i < 5; i++) {
//            dataURI = abi.encodePacked(dataURI,
//                '{"trait_type": "', _layerLabels[i], '",',
//                '"value": "', _traits[i][traits[i]],'"},'
//            );
//        }
//
//        return string(
//            abi.encodePacked(
//                "data:application/json;base64,",
//                Base64.encode(abi.encodePacked(dataURI, '{"trait_type": "Mouth", "value": "', _traits[5][traits[5]],'"}]}'))
//            )
//        );
//    }

    //// PRIVATE ////

    function _idToAddress(uint256 id) private pure returns (address) {
        return address(bytes20(bytes32(id) << 96));
    }

    // TODO MAKE PRIVATE

    function _addressToTraits(address addr) public view returns(uint256[10] memory) {
        bytes32 buffer = bytes32(bytes20(addr));

        uint256[10] memory traits;

        for (uint i = 0; i < 10; i++) {
            traits[i] = uint256(buffer << (i * 16) >> 240) % _traits[i].length;
        }

        return traits;
    }

}
