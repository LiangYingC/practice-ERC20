// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract TestERC20 {
    string public tokenName;
    string public tokenSymbol;
    uint256 public _totalSupply;

    // 第一個 address => A 地址 允許
    // 第二個 address => B 地址
    // uint256 => 動用的金額
    // 資料結構概念是：A address 允許 B address 動用 uint256 金額
    mapping(address => mapping(address => uint256)) public _allowance;
    // 資料結構的概念是：address 中擁有的餘額 uint256
    mapping(address => uint256) public _balance;

    // 實作當 TestERC20 new 出來時，可傳入 name 與 symbol，並設定完成
    constructor(string memory _name, string memory _symbol) {
        tokenName = _name;
        tokenSymbol = _symbol;
    }

    // 查詢 tokenName
    function name() public view returns (string memory) {
        return tokenName;
    }

    // 查詢 tokenSymbol
    function symbol() public view returns (string memory) {
        return tokenSymbol;
    }

    // 查詢 _totalSupply
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    // 實作 mint 鑄造發行功能，可傳入 to(給誰的地址)、amount(給多少 token)
    function mint(address to, uint256 amount) public {
        require(to != address(0)); // 確認不得發行給 address(0)，否則失敗
        _balance[to] += amount; // 將 to 地址增加 amount 的 token
        _totalSupply += amount; // 總供應量增加 amount 的 token
    }

    // 實作 burn 銷毀功能，可傳入 from(從哪個地址銷毀)、amount(銷毀多少 token)
    function burn(address from, uint256 amount) public {
        require(from != address(0)); // 確認不得銷毀 address(0) 中的 token，否則失敗
        _balance[from] -= amount; // 將 from 地址減少 amount 的 token
        _totalSupply -= amount; // 將總供應量減少 amount 的 token
    }

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balance[account]; // 回傳特定 account(地址) 的餘額，提供查詢
    }

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool) {
        require(_balance[msg.sender] >= value); // 確認目前發送轉帳的地址餘額大於想要轉帳的 token 數量
        require(to != address(0)); // 接收者不可以為 address(0)
        _balance[msg.sender] -= value; // 轉帳者的餘額要減少 value 的 token
        _balance[to] += value; // 接收者的餘額要加上 value 的 token
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        // 查詢目前授權的金額剩餘多少，查詢 owner 允許 spender 的授權金額
        return _allowance[owner][spender]; 
    }

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0)); // 花費者地址不為 address(0)
        require(msg.sender != address(0)); // 發送者 owner 不為 address(0)
        _allowance[msg.sender][spender] = value; // owner(msg.sender) 授權 spender 操作 value 數量的 token
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(_allowance[from][msg.sender] >= value); // 要先確認授權金額合法，owner(from) 授權給 spender(msg.sender，合約方) 的金額大於 value 數量的 token
        require(_balance[from] >= value); // owner(from) 本身目前的餘額，要大於 value 數量的 token，不能假授權
        _balance[from] -= value; // owner 的 token 下降
        _balance[to] += value; // taker 的 token 上升
        _allowance[from][msg.sender] -= value; // owner(from) 授權給 spender(msg.sender，合約方) 的數量要減少 value
        return true;
    }
}
