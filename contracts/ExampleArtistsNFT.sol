//SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.0;

import "./ArtistsNFT.sol";

contract ExampleArtistsNFT is ArtistsNFT {

  constructor(address artists, uint minimumSalePrice, string memory name, string memory symbol) ArtistsNFT(artists, minimumSalePrice, name, symbol) {
  
  }
  
}
