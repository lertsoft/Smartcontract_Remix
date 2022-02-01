//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
// tested components for smartcontracts
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
 
// Creation of the ERC721 contract 
contract RuralCity is Context,  AccessControlEnumerable, ERC721Enumerable, ERC721URIStorage, Ownable{
  using Counters for Counters.Counter;
  Counters.Counter public _tokenIdTracker;
 
  string private _baseTokenURI;
  uint private _price;
  uint private _max;
  address _wallet;
 
  bool _openMint;
  bool _openWhitelistMint;
 
  mapping(address => bool) private whitelist;
 
 // Different parameters for the contract and what the admin or user could potentially have access too
  constructor(string memory name, string memory symbol, string memory baseTokenURI, uint mintPrice, uint max, address wallet, address admin) ERC721(name, symbol) {
      _baseTokenURI = baseTokenURI;
      _price = mintPrice;
      _max = max;
      _wallet = wallet;
      _openMint = false;
      _openWhitelistMint = false;
      _setupRole(DEFAULT_ADMIN_ROLE, wallet);
      _setupRole(DEFAULT_ADMIN_ROLE, admin);
  }
 
 // Metadata server
  function _baseURI() internal view virtual override returns (string memory) {
      return _baseTokenURI;
  }
 
 // Metadata server
  function setBaseURI(string memory baseURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Rural&City: must have admin role to change base URI");
    _baseTokenURI = baseURI;
  }
 
  function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Rural&City: must have admin role to change token URI");
    _setTokenURI(tokenId, _tokenURI);
  }
 
 // Admin sets price of the NFT
  function setPrice(uint mintPrice) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Rural&City: must have admin role to change price");
    _price = mintPrice;
  }
 
 // Admin sets a bool statement to open or close the mint function on the contract
  function setMint(bool openMint, bool openWhitelistMint) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Rural&City: must have admin role to open/close mint");
    _openMint = openMint;
    _openWhitelistMint = openWhitelistMint;
  }
 
  function price() public view returns (uint) {
    return _price;
  }
 
 // Every mint increases the edition and ID of the ERC721 created
  function mint(address[] memory toSend ) public payable onlyOwner{
    require(toSend.length <= 2, "Rural&City: max of 2 Rural&City: per mint");
    require(_openMint == true, "Rural&City: minting is closed");
    require(msg.value == _price*toSend.length, "Rural&City: must send correct price");
    require(_tokenIdTracker.current() + toSend.length <= _max, "Rural&City: not enough Rural&City left to be mint amount");
    for(uint i = 0; i < toSend.length; i++) {
      _mint(toSend[i], _tokenIdTracker.current());
      _tokenIdTracker.increment();
    }
    payable(_wallet).transfer(msg.value);
  }
 
 //Addresses allowed to mint early
  function mintWhitelist() public payable {
    require(_openWhitelistMint == true, "Rural&City: minting is closed");
    require(whitelist[msg.sender] == true, "Rural&City: user must be whitelisted to mint");
    require(msg.value == _price, "Rural&City: must send correct price");
    require(_tokenIdTracker.current() < _max, "Rural&City: all Rural&City photos have been minted");
   
    whitelist[msg.sender] = false;
    _mint(msg.sender, _tokenIdTracker.current());
    _tokenIdTracker.increment();
    payable(_wallet).transfer(msg.value);
  }
 
 // Setting if whitelist address will be open or not 
  function whitelistUser(address user) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Rural&City: must have admin role to whitelist address");
    whitelist[user] = true;
  }
 
  function whitelistStatus(address user) public view returns(bool) {
    return whitelist[user];
  }
 
 // Delete of ERC721
  function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
    return ERC721URIStorage._burn(tokenId);
  }
 
  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return ERC721URIStorage.tokenURI(tokenId);
  }
 
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }
 
  function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}
