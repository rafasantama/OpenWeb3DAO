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
    string public licence_URI;
    IERC20 public ERC20Contract;
    IERC20 public cUSD;

    mapping (address => bool) public autorized; 
    mapping (address => bool) public whitelist; 
    mapping (uint => string) public NFTID2URI;


    constructor(string memory _licence_URI, address _cUSD_address) ERC721(InitName, InitSymbol) {
        licence_URI=_licence_URI;
        autorized[msg.sender]=true;
        cUSD = IERC20(_cUSD_address);
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
        return licence_URI;
    }
    function change_licenseURI(uint256 _token_Id, string memory _newURI) public onlyAutorized{
        NFTID2URI[_token_Id]=_newURI;
    }
    struct proposal{
        string name;
        uint value;
        bool state;
        bool cUSD;
        address owner;
    }
    proposal[] public proposals;
    function new_proposal(string memory _name) public payable {
        proposals.push(proposal(_name,msg.value,false,false,msg.sender));
        ERC20Contract.manager_mint(msg.sender,msg.value/4);
    }
    function new_proposal_cUSD(string memory _name, uint _cUSD_value) public {
        require(cUSD.balanceOf(_msgSender())>=_cUSD_value,"not enough cUSD");
        cUSD.transfer(address(this),_cUSD_value);
        proposals.push(proposal(_name,_cUSD_value,false,true,msg.sender));
    }
    function proposal_solution(uint _proposal_id, address _receiver)public {
        require(proposals[_proposal_id].owner==msg.sender,"only proposal creator can resolute");
        require(proposals[_proposal_id].state==false,"proposal already solved");
        if(proposals[_proposal_id].cUSD){
            cUSD.transferFrom(address(this),_msgSender(),proposals[_proposal_id].value);
        }
        else{
            ERC20Contract.manager_mint(_receiver,proposals[_proposal_id].value*3/4);
        }
        proposals[_proposal_id].state=true;
    }
    function free_code_copyright() public payable{
        require(msg.value>=10 * 10 ** 18,"minimun license doantion is 100 Celo");
        uint256 supply = totalSupply();
        totalMinted++;
        _safeMint(msg.sender, supply + 1);
    }
    function get_token_price() public view returns(uint _price) {
        return address(this).balance/ERC20Contract.totalSupply();
    }
    function sell_tokens(uint _amount) public {
        require(ERC20Contract.balanceOf(_msgSender())>=_amount,"amount to sell grater than balance");
        ERC20Contract.burn(_msgSender(),_amount);
        payable(_msgSender()).transfer(_amount*get_token_price());
    }
}
