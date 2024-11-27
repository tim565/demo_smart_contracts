// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";
import "@openzeppelin/contracts@5.0.0/interfaces/IERC2981.sol";

contract FancyNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 public royaltyPercentage = 500;  // 5% royalties
    mapping(uint256 => uint256) public tokenXP;

    constructor(address initialOwner) ERC721("FancyNFT", "FNT") Ownable(initialOwner) {}

    function safeMint(address to, string memory uri, uint256 categoryId, uint256 rarityLevel) public onlyOwner {
        uint256 tokenId = generateTokenId(categoryId, rarityLevel);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // The following functions provide additional specifications and features for the NFT
    function royaltyInfo(uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        return (owner(), (salePrice * royaltyPercentage) / 10000);
    }
    
    function addXP(uint256 tokenId, uint256 xp) public onlyOwner {
        tokenXP[tokenId] += xp;
    }

    /*
    * Allow the owner (or other authorized roles) to mint multiple NFTs at once in a batch, 
    * which could help in scenarios like a collection launch.
    */
    function batchMint(address to, uint256[] memory tokenIds, string[] memory uris) public onlyOwner {
        require(tokenIds.length == uris.length, "Array length mismatch");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _safeMint(to, tokenIds[i]);
            _setTokenURI(tokenIds[i], uris[i]);
        }
    }

    /*
    * Rather than manually assigning token IDs, in this NFT the IDs are generated uniquely by inserting the categoryId, rarityLevel and the signature. 
    */
    function generateTokenId(uint256 categoryId, uint256 rarityLevel) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(categoryId, rarityLevel, msg.sig)));
    }
}

