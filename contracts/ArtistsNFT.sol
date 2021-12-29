//SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

// Artist friendly NFT that enforces payment of royalties on every transfer.
// This differs from the current model, where whether royalties are respected
// is a matter of the platform, or parties, respecting it.

// ArtistsNFT allows the artist to declare a `minimumSalePrice` which must be met
// on every transfer, from which a royalty is extracted.

contract ArtistsNFT is ERC721, IERC2981 {

  address public artists;
  uint public minimumSalePrice;

  mapping (address => uint) public withdrawable;
  mapping (address => uint) public earned;

  constructor(address _artists, uint _minimumSalePrice, string memory name, string memory symbol) ERC721(name, symbol) {
    artists = _artists;
    minimumSalePrice = _minimumSalePrice; 
  }

  function _mint(address to, uint tokenId) internal override {
    require(msg.value >= minimumSalePrice, "minimumSalePrice must be met."); 
    super._mint(to, tokenId);
  }

  function _transfer(address from, address to, uint tokenId) internal override {
    require(msg.value >= minimumSalePrice, "minimumSalePrice must be met."); 
    super._transfer(from, to, tokenId);
  }

  function _beforeTokenTransfer(address from, address to, uint tokenId) internal override {
    (/*receiver is artists*/, uint royaltyAmount) = _royaltyInfo(tokenId, msg.value);
    unchecked {
      withdrawable[artists] += royaltyAmount;
      earned[artists] += royaltyAmount;
      // require(msg.value>=royaltyAmount, "msg.value less than royaltyAmount."); true by construction
      uint remaining = msg.value-royaltyAmount;
      withdrawable[from] += remaining;
      earned[from] += remaining;
    }
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function royaltyInfo(uint256 tokenId, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
    return _royaltyInfo(tokenId, salePrice);
  }

  function _royaltyInfo(uint256 tokenId, uint256 salePrice) internal view virtual returns (address receiver, uint256 royaltyAmount) {
    // must be overridden
  }

  function withdraw(address to, uint amount) external {
    require(withdrawable[msg.sender] >= amount, "amount exceeds withdrawable");
    unchecked {
      withdrawable[msg.sender] -= amount;
    }
    (bool success, ) = to.call{value: amount}("");
    require(success, "unable to send value, recipient may have reverted.");
  }

}
