// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * htOW3s://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function manager_mint(address receiver_,uint amount_) external;
    function burn(address _redeemAddress, uint256 _amount) external;
}

contract OW3NFTs is ERC721Enumerable {

    uint public totalMinted; //Cantidad total Minteada

    string InitName = "OW3NFTs"; 
    string InitSymbol = "OW3"; 
    IERC20 public ERC20Contract;
    mapping (address => bool) public autorized; 
    mapping (address => bool) public whitelist; 
    mapping (uint => string) public NFTID2URI;


    constructor() ERC721(InitName, InitSymbol) {
        autorized[msg.sender]=true;
    }

    function autorizeAddress(address _address) public onlyAutorized{
        autorized[_address]=true;
    }
    function whitelistAddress(address _address) public onlyAutorized{
        whitelist[_address]=true;
    }

    modifier onlyAutorized(){
        require(autorized[msg.sender],"Only autorized");
        _;
    }
    modifier onlyWhitelist(address address_){
        require(whitelist[address_],"Only whitelisted");
        _;
    }

    function setup_OW3ERC20(address _ERC20_add) public onlyAutorized{
        ERC20Contract=IERC20(_ERC20_add);
    }
    function mint_OW3ERC20(address receiver_, uint amount_) public onlyAutorized onlyWhitelist(receiver_){
        ERC20Contract.manager_mint(receiver_,amount_);
    }
    function mintOW3NFT(address receiver_,string memory _license_URI) public onlyAutorized onlyWhitelist(receiver_) {
        uint256 supply = totalSupply();
        totalMinted++;
        NFTID2URI[supply+1]=_license_URI;
        _safeMint(receiver_, supply + 1);
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

    function tokenURI(uint256 token_Id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(token_Id),
        "ERC721Metadata: URI query for nonexistent token"
        );
        return NFTID2URI[token_Id];
    }
    function change_licenseURI(uint256 _token_Id, string memory _newURI) public onlyAutorized{
        NFTID2URI[_token_Id]=_newURI;
    }

}
