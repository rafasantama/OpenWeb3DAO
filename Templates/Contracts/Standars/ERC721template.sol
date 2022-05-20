// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract OW3NFTs is ERC721Enumerable {

    uint public totalMinted;
    mapping (address => bool) public autorized;
    using Strings for uint256;
    string InitName = "OW3NFTs";
    string InitSymbol = "OW3";
    uint256 specialMinted;
    uint256 founderPercentage=10;
    address royaltyReceiver;
    mapping  (uint => string) public ID2URI;

    constructor() ERC721(InitName, InitSymbol) {
        autorized[msg.sender]=true;
        royaltyReceiver=msg.sender;
    }

    function autorizeAddress(address _address) public onlyAutorized{
        autorized[_address]=true;
    }

    modifier onlyAutorized(){
        require(autorized[msg.sender],"Only autorized");
        _;
    }

    function mint(address _to, string memory _specialURI) public onlyAutorized {
        uint256 supply = totalSupply();
        totalMinted++;
        ID2URI[supply+1]=_specialURI;
        _safeMint(_to, supply + 1);
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }     

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(_tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );
        return ID2URI[_tokenId];
    }
    function change_tokenURI(uint256 _tokenId, string memory _newURI) public onlyAutorized{
        require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
        ID2URI[_tokenId]=_newURI;
    }
    function royaltyInfo(uint256 _tokenId,uint256 _salePrice) public view returns (address receiver, uint256 royaltyAmount){
        _tokenId+0;
        return(royaltyReceiver, _salePrice*(founderPercentage)/100);
    }
    function changeRoyaltyFounderInfo(address _royaltyReceiver) public onlyAutorized{
        royaltyReceiver=_royaltyReceiver;
    }
}
