// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// File: contracts\IERC20Extended.sol

pragma solidity ^0.8.0;


interface IERC20Extended is IERC20 {
    function decimals() external view returns (uint8);
}

// File: contracts\TokenFaucet.sol

pragma solidity ^0.8.0;


// Multi-Token Faucet
contract TokenFaucet {
    address public owner; // owner of the faucet
    uint256 public timer = 1 days; // timer of dispense time
    uint256 public  dispenseValue = 10000000000000000000; // value for every dispense

    mapping(address => mapping(address => uint256)) public cannotDispenseUntil; // time until user can dispense for every token

    // verification account already asked for a dispense before enough time has passed
    modifier timePassed(IERC20Extended token, address to) {
        require(cannotDispenseUntil[address(token)][msg.sender] < block.timestamp, "Not enough time between dispenses");
        _;
        cannotDispenseUntil[address(token)][msg.sender] = block.timestamp + timer;
    }  

    // modifier for owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Owner-only function");
        _;
    } 

    // ask for dispense
    function dispense(IERC20Extended token, address to) public timePassed(token, to) {
        token.transfer(to, dispenseValue);
    }

    // ADMIN FUNCTIONS:

    // arbitrary withdrawal of any token (owner-only)
    function withdraw(
        IERC20Extended token,
        address to,
        uint256 value
    ) public onlyOwner {
        token.transfer(to, value);
    }

    // select timer reset time (owner-only)
    function selectTime(uint256 _timer) public onlyOwner {        
        timer = _timer;
    }

    // select dispense value (owner-only)
    function selectDispenseValue(uint256 _dispenseValue) public onlyOwner {        
        dispenseValue = _dispenseValue;
    }

    // constructor
    constructor() public {
        owner = msg.sender;
    }
}
