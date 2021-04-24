// Dependency file: contracts/core/objects/LoanStruct.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


contract LoanStruct {
    struct Loan {
        bytes32 id;                 // id of the loan
        bytes32 loanParamsId;       // the linked loan params id
        bytes32 pendingTradesId;    // the linked pending trades id
        bool active;                // if false, the loan has been fully closed
        uint256 principal;          // total borrowed amount outstanding
        uint256 collateral;         // total collateral escrowed for the loan
        uint256 startTimestamp;     // loan start time
        uint256 endTimestamp;       // for active loans, this is the expected loan end time, for in-active loans, is the actual (past) end time
        uint256 startMargin;        // initial margin when the loan opened
        uint256 startRate;          // reference rate when the loan opened for converting collateralToken to loanToken
        address borrower;           // borrower of this loan
        address lender;             // lender of this loan
    }
}


// Dependency file: contracts/core/objects/LoanParamsStruct.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


contract LoanParamsStruct {
    struct LoanParams {
        bytes32 id;                 // id of loan params object
        bool active;                // if false, this object has been disabled by the owner and can't be used for future loans
        address owner;              // owner of this object
        address loanToken;          // the token being loaned
        address collateralToken;    // the required collateral token
        uint256 minInitialMargin;   // the minimum allowed initial margin
        uint256 maintenanceMargin;  // an unhealthy loan when current margin is at or below this value
        uint256 maxLoanTerm;        // the maximum term for new loans (0 means there's no max term)
    }
}


// Dependency file: contracts/core/objects/OrderStruct.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


contract OrderStruct {
    struct Order {
        uint256 lockedAmount;           // escrowed amount waiting for a counterparty
        uint256 interestRate;           // interest rate defined by the creator of this order
        uint256 minLoanTerm;            // minimum loan term allowed
        uint256 maxLoanTerm;            // maximum loan term allowed
        uint256 createdTimestamp;       // timestamp when this order was created
        uint256 expirationTimestamp;    // timestamp when this order expires
    }
}


// Dependency file: contracts/core/objects/LenderInterestStruct.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


contract LenderInterestStruct {
    struct LenderInterest {
        uint256 principalTotal;     // total borrowed amount outstanding of asset
        uint256 owedPerDay;         // interest owed per day for all loans of asset
        uint256 owedTotal;          // total interest owed for all loans of asset (assuming they go to full term)
        uint256 paidTotal;          // total interest paid so far for asset
        uint256 updatedTimestamp;   // last update
    }
}


// Dependency file: contracts/core/objects/LoanInterestStruct.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


contract LoanInterestStruct {
    struct LoanInterest {
        uint256 owedPerDay;         // interest owed per day for loan
        uint256 depositTotal;       // total escrowed interest for loan
        uint256 updatedTimestamp;   // last update
    }
}


// Dependency file: contracts/core/Objects.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;

// import "contracts/core/objects/LoanStruct.sol";
// import "contracts/core/objects/LoanParamsStruct.sol";
// import "contracts/core/objects/OrderStruct.sol";
// import "contracts/core/objects/LenderInterestStruct.sol";
// import "contracts/core/objects/LoanInterestStruct.sol";


contract Objects is
    LoanStruct,
    LoanParamsStruct,
    OrderStruct,
    LenderInterestStruct,
    LoanInterestStruct
{}

// Dependency file: contracts/mixins/EnumerableBytes32Set.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;

/**
 * @dev Library for managing loan sets
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * Include with `using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;`.
 *
 */
library EnumerableBytes32Set {

    struct Bytes32Set {
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) index;
        bytes32[] values;
    }

    /**
     * @dev Add an address value to a set. O(1).
     * Returns false if the value was already in the set.
     */
    function addAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {
        bytes32 value;
        assembly {
            value := addrvalue
        }
        return addBytes32(set, value);
    }

    /**
     * @dev Add a value to a set. O(1).
     * Returns false if the value was already in the set.
     */
    function addBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        if (!contains(set, value)){
            set.index[value] = set.values.push(value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes an address value from a set. O(1).
     * Returns false if the value was not present in the set.
     */
    function removeAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {
        bytes32 value;
        assembly {
            value := addrvalue
        }
        return removeBytes32(set, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     * Returns false if the value was not present in the set.
     */
    function removeBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        if (contains(set, value)){
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

            // If the element we're deleting is the last one, we can just remove it without doing a swap
            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set.values[lastIndex];

                // Move the last value to the index where the deleted value is
                set.values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set.index[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            // Delete the index entry for the deleted value
            delete set.index[value];

            // Delete the old entry for the moved value
            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return set.index[value] != 0;
    }

    /**
     * @dev Returns an array with all values in the set. O(N).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.

     * WARNING: This function may run out of gas on large sets: use {length} and
     * {get} instead in these cases.
     */
    function enumerate(Bytes32Set storage set, uint256 start, uint256 count)
        internal
        view
        returns (bytes32[] memory output)
    {
        uint256 end = start + count;
        require(end >= start, "addition overflow");
        end = set.values.length < end ? set.values.length : end;
        if (end == 0 || start >= end) {
            return output;
        }

        output = new bytes32[](end-start);
        for (uint256 i; i < end-start; i++) {
            output[i] = set.values[i+start];
        }
        return output;
    }

    /**
     * @dev Returns the number of elements on the set. O(1).
     */
    function length(Bytes32Set storage set)
        internal
        view
        returns (uint256)
    {
        return set.values.length;
    }

   /** @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function get(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return set.values[index];
    }
}


// Dependency file: contracts/openzeppelin/ReentrancyGuard.sol


// pragma solidity >=0.5.0 <0.6.0;


/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

    /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
    /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
    uint256 internal constant REENTRANCY_GUARD_FREE = 1;

    /// @dev Constant for locked guard state
    uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;

    /**
    * @dev We use a single lock for the whole contract.
    */
    uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;

    /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * If you mark a function `nonReentrant`, you should also
    * mark it `external`. Calling one `nonReentrant` function from
    * another is not supported. Instead, you can implement a
    * `private` function doing the actual work, and an `external`
    * wrapper marked as `nonReentrant`.
    */
    modifier nonReentrant() {
        require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");
        reentrancyLock = REENTRANCY_GUARD_LOCKED;
        _;
        reentrancyLock = REENTRANCY_GUARD_FREE;
    }

}


// Dependency file: contracts/openzeppelin/Context.sol


// pragma solidity >=0.5.0 <0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Dependency file: contracts/openzeppelin/Ownable.sol


// pragma solidity >=0.5.0 <0.6.0;

// import "contracts/openzeppelin/Context.sol";


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "unauthorized");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// Dependency file: contracts/openzeppelin/SafeMath.sol


// pragma solidity >=0.5.0 <0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a < _b ? _a : _b;
    }
}


// Dependency file: contracts/interfaces/IWrbtc.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity >=0.5.0 <0.6.0;


interface IWrbtc {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}


// Dependency file: contracts/interfaces/IERC20.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity >=0.5.0 <0.6.0;


contract IERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// Dependency file: contracts/interfaces/IWrbtcERC20.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity >=0.5.0 <0.6.0;

// import "contracts/interfaces/IWrbtc.sol";
// import "contracts/interfaces/IERC20.sol";


contract IWrbtcERC20 is IWrbtc, IERC20 {}


// Dependency file: contracts/core/State.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


// import "contracts/core/Objects.sol";
// import "contracts/mixins/EnumerableBytes32Set.sol";
// import "contracts/openzeppelin/ReentrancyGuard.sol";
// import "contracts/openzeppelin/Ownable.sol";
// import "contracts/openzeppelin/SafeMath.sol";
// import "contracts/interfaces/IWrbtcERC20.sol";


contract State is Objects, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;

    address public priceFeeds;                                                          // handles asset reference price lookups
    address public swapsImpl;                                                           // handles asset swaps using dex liquidity
    address public sovrynSwapContractRegistryAddress;                                       // contract registry address of the sovryn swap network

    mapping (bytes4 => address) public logicTargets;                                    // implementations of protocol functions

    mapping (bytes32 => Loan) public loans;                                             // loanId => Loan
    mapping (bytes32 => LoanParams) public loanParams;                                  // loanParamsId => LoanParams

    mapping (address => mapping (bytes32 => Order)) public lenderOrders;                // lender => orderParamsId => Order
    mapping (address => mapping (bytes32 => Order)) public borrowerOrders;              // borrower => orderParamsId => Order

    mapping (bytes32 => mapping (address => bool)) public delegatedManagers;            // loanId => delegated => approved

    // Interest
    mapping (address => mapping (address => LenderInterest)) public lenderInterest;     // lender => loanToken => LenderInterest object
    mapping (bytes32 => LoanInterest) public loanInterest;                              // loanId => LoanInterest object

    // Internals
    EnumerableBytes32Set.Bytes32Set internal logicTargetsSet;                           // implementations set
    EnumerableBytes32Set.Bytes32Set internal activeLoansSet;                            // active loans set

    mapping (address => EnumerableBytes32Set.Bytes32Set) internal lenderLoanSets;       // lender loans set
    mapping (address => EnumerableBytes32Set.Bytes32Set) internal borrowerLoanSets;     // borrow loans set
    mapping (address => EnumerableBytes32Set.Bytes32Set) internal userLoanParamSets;    // user loan params set

    address public feesController;                                                      // address controlling fee withdrawals

    uint256 public lendingFeePercent = 10**19; // 10% fee                               // fee taken from lender interest payments
    mapping (address => uint256) public lendingFeeTokensHeld;                           // total interest fees received and not withdrawn per asset
    mapping (address => uint256) public lendingFeeTokensPaid;                           // total interest fees withdraw per asset (lifetime fees = lendingFeeTokensHeld + lendingFeeTokensPaid)

    uint256 public tradingFeePercent = 15 * 10**16; // 0.15% fee                        // fee paid for each trade
    mapping (address => uint256) public tradingFeeTokensHeld;                           // total trading fees received and not withdrawn per asset
    mapping (address => uint256) public tradingFeeTokensPaid;                           // total trading fees withdraw per asset (lifetime fees = tradingFeeTokensHeld + tradingFeeTokensPaid)

    uint256 public borrowingFeePercent = 9 * 10**16; // 0.09% fee                       // origination fee paid for each loan
    mapping (address => uint256) public borrowingFeeTokensHeld;                         // total borrowing fees received and not withdrawn per asset
    mapping (address => uint256) public borrowingFeeTokensPaid;                         // total borrowing fees withdraw per asset (lifetime fees = borrowingFeeTokensHeld + borrowingFeeTokensPaid)

    uint256 public protocolTokenHeld;                                                   // current protocol token deposit balance
    uint256 public protocolTokenPaid;                                                   // lifetime total payout of protocol token

    uint256 public affiliateFeePercent = 30 * 10**18; // 30% fee share                  // fee share for affiliate program

    uint256 public liquidationIncentivePercent = 5 * 10**18; // 5% collateral discount  // discount on collateral for liquidators

    mapping (address => address) public loanPoolToUnderlying;                            // loanPool => underlying
    mapping (address => address) public underlyingToLoanPool;                            // underlying => loanPool
    EnumerableBytes32Set.Bytes32Set internal loanPoolsSet;                               // loan pools set

    mapping (address => bool) public supportedTokens;                                    // supported tokens for swaps

    uint256 public maxDisagreement = 5 * 10**18;                                         // % disagreement between swap rate and reference rate

    uint256 public sourceBuffer = 10000;                                                 // used as buffer for swap source amount estimations

    uint256 public maxSwapSize = 50 ether;                                               // maximum support swap size in BTC

    mapping(address => uint256) public borrowerNonce;                                    // nonce per borrower. used for loan id creation.

    uint256 public rolloverBaseReward = 16800000000000;                                  // Rollover transaction costs around 0.0000168 rBTC, it is denominated in wRBTC
    uint256 public rolloverFlexFeePercent = 0.1 ether;                                   // 0.1%

    IWrbtcERC20 public wrbtcToken;
    address public protocolTokenAddress;

    function _setTarget(
        bytes4 sig,
        address target)
        internal
    {
        logicTargets[sig] = target;

        if (target != address(0)) {
            logicTargetsSet.addBytes32(bytes32(sig));
        } else {
            logicTargetsSet.removeBytes32(bytes32(sig));
        }
    }
}


// Dependency file: contracts/events/LoanClosingsEvents.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


contract LoanClosingsEvents {

    // topic0: 0x6349c1a02ec126f7f4fc6e6837e1859006e90e9901635c442d29271e77b96fb6
    event CloseWithDeposit(
        address indexed user,
        address indexed lender,
        bytes32 indexed loanId,
        address closer,
        address loanToken,
        address collateralToken,
        uint256 repayAmount,
        uint256 collateralWithdrawAmount,
        uint256 collateralToLoanRate,
        uint256 currentMargin
    );

    // topic0: 0x2ed7b29b4ca95cf3bb9a44f703872a66e6aa5e8f07b675fa9a5c124a1e5d7352
    event CloseWithSwap(
        address indexed user,
        address indexed lender,
        bytes32 indexed loanId,
        address collateralToken,
        address loanToken,
        address closer,
        uint256 positionCloseSize,
        uint256 loanCloseAmount,
        uint256 exitPrice, // one unit of collateralToken, denominated in loanToken
        uint256 currentLeverage
    );

    // topic0: 0x46fa03303782eb2f686515f6c0100f9a62dabe587b0d3f5a4fc0c822d6e532d3
    event Liquidate(
        address indexed user,
        address indexed liquidator,
        bytes32 indexed loanId,
        address lender,
        address loanToken,
        address collateralToken,
        uint256 repayAmount,
        uint256 collateralWithdrawAmount,
        uint256 collateralToLoanRate,
        uint256 currentMargin
    );
    
    event swapExcess(
        bool shouldRefund, 
        uint amount, 
        uint amountInRbtc, 
        uint threshold
    );
}


// Dependency file: contracts/openzeppelin/Address.sol


// pragma solidity >=0.5.0 <0.6.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [// importANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * // importANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


// Dependency file: contracts/openzeppelin/SafeERC20.sol


// pragma solidity >=0.5.0 <0.6.0;

// import "contracts/openzeppelin/SafeMath.sol";
// import "contracts/openzeppelin/Address.sol";
// import "contracts/interfaces/IERC20.sol";


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// Dependency file: contracts/mixins/VaultController.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;

// import "contracts/openzeppelin/SafeERC20.sol";
// import "contracts/core/State.sol";


contract VaultController is State {
    using SafeERC20 for IERC20;

    event VaultDeposit(
        address indexed asset,
        address indexed from,
        uint256 amount
    );
    event VaultWithdraw(
        address indexed asset,
        address indexed to,
        uint256 amount
    );

    function vaultEtherDeposit(
        address from,
        uint256 value)
        internal
    {
        IWrbtcERC20 _wrbtcToken = wrbtcToken;
        _wrbtcToken.deposit.value(value)();

        emit VaultDeposit(
            address(_wrbtcToken),
            from,
            value
        );
    }

    function vaultEtherWithdraw(
        address to,
        uint256 value)
        internal
    {
        if (value != 0) {
            IWrbtcERC20 _wrbtcToken = wrbtcToken;
            uint256 balance = address(this).balance;
            if (value > balance) {
                _wrbtcToken.withdraw(value - balance);
            }
            Address.sendValue(to, value);

            emit VaultWithdraw(
                address(_wrbtcToken),
                to,
                value
            );
        }
    }

    function vaultDeposit(
        address token,
        address from,
        uint256 value)
        internal
    {
        if (value != 0) {
            IERC20(token).safeTransferFrom(
                from,
                address(this),
                value
            );

            emit VaultDeposit(
                token,
                from,
                value
            );
        }
    }

    function vaultWithdraw(
        address token,
        address to,
        uint256 value)
        internal
    {
        if (value != 0) {
            IERC20(token).safeTransfer(
                to,
                value
            );

            emit VaultWithdraw(
                token,
                to,
                value
            );
        }
    }

    function vaultTransfer(
        address token,
        address from,
        address to,
        uint256 value)
        internal
    {
        if (value != 0) {
            if (from == address(this)) {
                IERC20(token).safeTransfer(
                    to,
                    value
                );
            } else {
                IERC20(token).safeTransferFrom(
                    from,
                    to,
                    value
                );
            }
        }
    }

    function vaultApprove(
        address token,
        address to,
        uint256 value)
        internal
    {
        if (value != 0 && IERC20(token).allowance(address(this), to) != 0) {
            IERC20(token).safeApprove(to, 0);
        }
        IERC20(token).safeApprove(to, value);
    }
}


// Dependency file: contracts/feeds/IPriceFeeds.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


interface IPriceFeeds {
    function queryRate(
        address sourceToken,
        address destToken)
        external
        view
        returns (uint256 rate, uint256 precision);

    function queryPrecision(
        address sourceToken,
        address destToken)
        external
        view
        returns (uint256 precision);

    function queryReturn(
        address sourceToken,
        address destToken,
        uint256 sourceAmount)
        external
        view
        returns (uint256 destAmount);

    function checkPriceDisagreement(
        address sourceToken,
        address destToken,
        uint256 sourceAmount,
        uint256 destAmount,
        uint256 maxSlippage)
        external
        view
        returns (uint256 sourceToDestSwapRate);

    function amountInEth(
        address Token,
        uint256 amount)
        external
        view
        returns (uint256 ethAmount);

    function getMaxDrawdown(
        address loanToken,
        address collateralToken,
        uint256 loanAmount,
        uint256 collateralAmount,
        uint256 maintenanceMargin)
        external
        view
        returns (uint256);

    function getCurrentMarginAndCollateralSize(
        address loanToken,
        address collateralToken,
        uint256 loanAmount,
        uint256 collateralAmount)
        external
        view
        returns (uint256 currentMargin, uint256 collateralInEthAmount);

    function getCurrentMargin(
        address loanToken,
        address collateralToken,
        uint256 loanAmount,
        uint256 collateralAmount)
        external
        view
        returns (uint256 currentMargin, uint256 collateralToLoanRate);

    function shouldLiquidate(
        address loanToken,
        address collateralToken,
        uint256 loanAmount,
        uint256 collateralAmount,
        uint256 maintenanceMargin)
        external
        view
        returns (bool);

    function getFastGasPrice(
        address payToken)
        external
        view
        returns (uint256);
}


// Dependency file: contracts/events/FeesEvents.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


contract FeesEvents {
    event PayLendingFee(
        address indexed payer,
        address indexed token,
        uint256 amount
    );

    event PayTradingFee(
        address indexed payer,
        address indexed token,
        bytes32 indexed loanId,
        uint256 amount
    );

    event PayBorrowingFee(
        address indexed payer,
        address indexed token,
        bytes32 indexed loanId,
        uint256 amount
    );

    event EarnReward(
        address indexed receiver,
        address indexed token,
        bytes32 indexed loanId,
        uint256 amount
    );
}

// Dependency file: contracts/mixins/ProtocolTokenUser.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;

// import "contracts/core/State.sol";
// import "contracts/openzeppelin/SafeERC20.sol";


contract ProtocolTokenUser is State {
    using SafeERC20 for IERC20;

    function _withdrawProtocolToken(
        address receiver,
        uint256 amount)
        internal
        returns (address, bool)
    {
        uint256 withdrawAmount = amount;

        uint256 tokenBalance = protocolTokenHeld;
        if (withdrawAmount > tokenBalance) {
            withdrawAmount = tokenBalance;
        }
        if (withdrawAmount == 0) {
            return (protocolTokenAddress, false);
        }

        protocolTokenHeld = tokenBalance
            .sub(withdrawAmount);

        IERC20(protocolTokenAddress).safeTransfer(
            receiver,
            withdrawAmount
        );

        return (protocolTokenAddress, true);
    }
}

// Dependency file: contracts/mixins/FeesHelper.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;

// import "contracts/core/State.sol";
// import "contracts/openzeppelin/SafeERC20.sol";
// import "contracts/feeds/IPriceFeeds.sol";
// import "contracts/events/FeesEvents.sol";
// import "contracts/mixins/ProtocolTokenUser.sol";


contract FeesHelper is State, ProtocolTokenUser, FeesEvents {
    using SafeERC20 for IERC20;

    // calculate trading fee
    function _getTradingFee(
        uint256 feeTokenAmount)
        internal
        view
        returns (uint256)
    {
        return feeTokenAmount
            .mul(tradingFeePercent)
            .div(10**20);
    }

    // calculate loan origination fee
    function _getBorrowingFee(
        uint256 feeTokenAmount)
        internal
        view
        returns (uint256)
    {
        return feeTokenAmount
            .mul(borrowingFeePercent)
            .div(10**20);
    }
    
    /**
     * @dev settles the trading fee and pays the token reward to the user.
     * @param user the address to send the reward to
     * @param loanId the Id of the associated loan - used for logging only.
     * @param feeToken the address of the token in which the trading fee is paid
     * */
    function _payTradingFee(
        address user,
        bytes32 loanId,
        address feeToken,
        uint256 tradingFee)
        internal
    {
        if (tradingFee != 0) {
            //increase the storage variable keeping track of the accumulated fees
            tradingFeeTokensHeld[feeToken] = tradingFeeTokensHeld[feeToken]
                .add(tradingFee);

            emit PayTradingFee(
                user,
                feeToken,
                loanId,
                tradingFee
            );
            
            //pay the token reward to the user
            _payFeeReward(
                user,
                loanId,
                feeToken,
                tradingFee
            );
        }
    }
    
    /**
     * @dev settles the borrowing fee and pays the token reward to the user.
     * @param user the address to send the reward to
     * @param loanId the Id of the associated loan - used for logging only.
     * @param feeToken the address of the token in which the borrowig fee is paid
     * @param borrowingFee the height of the fee
     * */
    function _payBorrowingFee(
        address user,
        bytes32 loanId,
        address feeToken,
        uint256 borrowingFee)
        internal
    {
        if (borrowingFee != 0) {
            //increase the storage variable keeping track of the accumulated fees
            borrowingFeeTokensHeld[feeToken] = borrowingFeeTokensHeld[feeToken]
                .add(borrowingFee);

            emit PayBorrowingFee(
                user,
                feeToken,
                loanId,
                borrowingFee
            );
            //pay the token reward to the user
            _payFeeReward(
                user,
                loanId,
                feeToken,
                borrowingFee
            );
        }
    }

    /**
     * @dev settles the lending fee (based on the interest). Pays no token reward to the user.
     * @param user the address to send the reward to
     * @param feeToken the address of the token in which the lending fee is paid
     * @param lendingFee the height of the fee
     * */
    function _payLendingFee(
        address user,
        address feeToken,
        uint256 lendingFee)
        internal
    {
        if (lendingFee != 0) {
            //increase the storage variable keeping track of the accumulated fees
            lendingFeeTokensHeld[feeToken] = lendingFeeTokensHeld[feeToken]
                .add(lendingFee);

            emit PayLendingFee(
                user,
                feeToken,
                lendingFee
            );

             //// NOTE: Lenders do not receive a fee reward ////
        }
    }

    // settles and pays borrowers based on the fees generated by their interest payments
    function _settleFeeRewardForInterestExpense(
        LoanInterest storage loanInterestLocal,
        bytes32 loanId,
        address feeToken,
        address user,
        uint256 interestTime)
        internal
    {
        // this represents the fee generated by a borrower's interest payment
        uint256 interestExpenseFee = interestTime
            .sub(loanInterestLocal.updatedTimestamp)
            .mul(loanInterestLocal.owedPerDay)
            .div(86400)
            .mul(lendingFeePercent)
            .div(10**20);

        loanInterestLocal.updatedTimestamp = interestTime;

        if (interestExpenseFee != 0) {
            _payFeeReward(
                user,
                loanId,
                feeToken,
                interestExpenseFee
            );
        }
    }


    /**
     * @dev pays the potocolToken reward to user. The reward is worth 50% of the trading/borrowing fee.
     * @param user the address to send the reward to
     * @param loanId the Id of the associeated loan - used for logging only.
     * @param feeToken the address of the token in which the trading/borrowig fee was paid
     * @param feeAmount the height of the fee
     * */
    function _payFeeReward(
        address user,
        bytes32 loanId,
        address feeToken,
        uint256 feeAmount)
        internal
    {
        uint256 rewardAmount;
        address _priceFeeds = priceFeeds;
        //note: this should be refactored.
        //calculate the reward amount, querying the price feed
        (bool success, bytes memory data) = _priceFeeds.staticcall(
            abi.encodeWithSelector(
                IPriceFeeds(_priceFeeds).queryReturn.selector,
                feeToken,
                protocolTokenAddress, // price rewards using BZRX price rather than vesting token price
                feeAmount / 2  // 50% of fee value
            )
        );
        assembly {
            if eq(success, 1) {
                rewardAmount := mload(add(data, 32))
            }
        }

        if (rewardAmount != 0) {
            address rewardToken;
            (rewardToken, success) = _withdrawProtocolToken(
                user,
                rewardAmount
            );
            if (success) {
                protocolTokenPaid = protocolTokenPaid
                    .add(rewardAmount);

                emit EarnReward(
                    user,
                    rewardToken,
                    loanId,
                    rewardAmount
                );
            }
        }
    }
}

// Dependency file: contracts/mixins/InterestUser.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;

// import "contracts/openzeppelin/SafeERC20.sol";
// import "contracts/core/State.sol";
// import "contracts/mixins/VaultController.sol";
// import "contracts/mixins/FeesHelper.sol";


contract InterestUser is VaultController, FeesHelper {
    using SafeERC20 for IERC20;

    function _payInterest(
        address lender,
        address interestToken)
        internal
    {
        LenderInterest storage lenderInterestLocal = lenderInterest[lender][interestToken];

        uint256 interestOwedNow = 0;
        if (lenderInterestLocal.owedPerDay != 0 && lenderInterestLocal.updatedTimestamp != 0) {
            interestOwedNow = block.timestamp
                .sub(lenderInterestLocal.updatedTimestamp)
                .mul(lenderInterestLocal.owedPerDay)
                .div(86400);

            if (interestOwedNow > lenderInterestLocal.owedTotal)
	            interestOwedNow = lenderInterestLocal.owedTotal;

            if (interestOwedNow != 0) {
                lenderInterestLocal.paidTotal = lenderInterestLocal.paidTotal
                    .add(interestOwedNow);
                lenderInterestLocal.owedTotal = lenderInterestLocal.owedTotal
                    .sub(interestOwedNow);

                _payInterestTransfer(
                    lender,
                    interestToken,
                    interestOwedNow
                );
            }
        }

        lenderInterestLocal.updatedTimestamp = block.timestamp;
    }

    function _payInterestTransfer(
        address lender,
        address interestToken,
        uint256 interestOwedNow)
        internal
    {
        uint256 lendingFee = interestOwedNow
            .mul(lendingFeePercent)
            .div(10**20);

        _payLendingFee(
            lender,
            interestToken,
            lendingFee
        );

        // transfers the interest to the lender, less the interest fee
        vaultWithdraw(
            interestToken,
            lender,
            interestOwedNow
                .sub(lendingFee)
        );
    }
}


// Dependency file: contracts/mixins/LiquidationHelper.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;

// import "contracts/core/State.sol";


contract LiquidationHelper is State {
    
    /**
     * computes how much needs to be liquidated in order to restore the desired margin (maintenance + 5%)
     * @param principal total borrowed amount (in loan tokens)
     * @param collateral the collateral (in collateral tokens)
     * @param currentMargin the current margin
     * @param maintenanceMargin the maintenance (minimum) margin
     * @param collateralToLoanRate the exchange rate from collateral to loan tokens
     * */
    function _getLiquidationAmounts(
        uint256 principal,
        uint256 collateral,
        uint256 currentMargin,
        uint256 maintenanceMargin,
        uint256 collateralToLoanRate)
        internal
        view
        returns (uint256 maxLiquidatable, uint256 maxSeizable, uint256 incentivePercent)
    {
        incentivePercent = liquidationIncentivePercent;
        if (currentMargin > maintenanceMargin || collateralToLoanRate == 0) {
            return (maxLiquidatable, maxSeizable, incentivePercent);
        } else if (currentMargin <= incentivePercent) {
            return (principal, collateral, currentMargin);
        }

        uint256 desiredMargin = maintenanceMargin
            .add(5 ether); // 5 percentage points above maintenance

        // maxLiquidatable = ((1 + desiredMargin)*principal - collateralToLoanRate*collateral) / (desiredMargin - 0.05)
        maxLiquidatable = desiredMargin
            .add(10**20)
            .mul(principal)
            .div(10**20);
        maxLiquidatable = maxLiquidatable
            .sub(
                collateral
                    .mul(collateralToLoanRate)
                    .div(10**18)
            );
        maxLiquidatable = maxLiquidatable
            .mul(10**20)
            .div(
                desiredMargin
                    .sub(incentivePercent)
            );
        if (maxLiquidatable > principal) {
            maxLiquidatable = principal;
        }

        // maxSeizable = maxLiquidatable * (1 + incentivePercent) / collateralToLoanRate
        maxSeizable = maxLiquidatable
            .mul(
                incentivePercent
                    .add(10**20)
            );
        maxSeizable = maxSeizable
            .div(collateralToLoanRate)
            .div(100);
        if (maxSeizable > collateral) {
            maxSeizable = collateral;
        }

        return (maxLiquidatable, maxSeizable, incentivePercent);
    }
}


// Dependency file: contracts/events/SwapsEvents.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


contract SwapsEvents {
    event LoanSwap(
        bytes32 indexed loanId,
        address indexed sourceToken,
        address indexed destToken,
        address borrower,
        uint256 sourceAmount,
        uint256 destAmount
    );

    event ExternalSwap(
        address indexed user,
        address indexed sourceToken,
        address indexed destToken,
        uint256 sourceAmount,
        uint256 destAmount
    );
}


// Dependency file: contracts/swaps/ISwapsImpl.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;


interface ISwapsImpl {
    function internalSwap(
        address sourceTokenAddress,
        address destTokenAddress,
        address receiverAddress,
        address returnToSenderAddress,
        uint256 minSourceTokenAmount,
        uint256 maxSourceTokenAmount,
        uint256 requiredDestTokenAmount)
        external
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed);

    function internalExpectedRate(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount)
        external
        view
        returns (uint256);
}


// Dependency file: contracts/swaps/SwapsUser.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity 0.5.17;

// import "contracts/core/State.sol";
// import "contracts/feeds/IPriceFeeds.sol";
// import "contracts/events/SwapsEvents.sol";
// import "contracts/mixins/FeesHelper.sol";
// import "contracts/swaps/ISwapsImpl.sol";


contract SwapsUser is State, SwapsEvents, FeesHelper {

    function _loanSwap(
        bytes32 loanId,
        address sourceToken,
        address destToken,
        address user,
        uint256 minSourceTokenAmount,
        uint256 maxSourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bool bypassFee,
        bytes memory loanDataBytes)
        internal
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed, uint256 sourceToDestSwapRate)
    {
        (destTokenAmountReceived, sourceTokenAmountUsed) = _swapsCall(
            [
                sourceToken,
                destToken,
                address(this), // receiver
                address(this), // returnToSender
                user
            ],
            [
                minSourceTokenAmount,
                maxSourceTokenAmount,
                requiredDestTokenAmount
            ],
            loanId,
            bypassFee,
            loanDataBytes
        );

        // will revert if swap size too large
        _checkSwapSize(sourceToken, sourceTokenAmountUsed);

        // will revert if disagreement found
        sourceToDestSwapRate = IPriceFeeds(priceFeeds).checkPriceDisagreement(
            sourceToken,
            destToken,
            sourceTokenAmountUsed,
            destTokenAmountReceived,
            maxDisagreement
        );

        emit LoanSwap(
            loanId,
            sourceToken,
            destToken,
            user,
            sourceTokenAmountUsed,
            destTokenAmountReceived
        );
    }

    function _swapsCall(
        address[5] memory addrs,
        uint256[3] memory vals,
        bytes32 loanId,
        bool miscBool, // bypassFee
        bytes memory loanDataBytes)
        internal
        returns (uint256, uint256)
    {
        //addrs[0]: sourceToken
        //addrs[1]: destToken
        //addrs[2]: receiver
        //addrs[3]: returnToSender
        //addrs[4]: user
        //vals[0]:  minSourceTokenAmount
        //vals[1]:  maxSourceTokenAmount
        //vals[2]:  requiredDestTokenAmount

        require(vals[0] != 0 || vals[1] != 0, "min or max source token amount needs to be set");

        if (vals[1] == 0) {
            vals[1] = vals[0];
        }
        require(vals[0] <= vals[1], "sourceAmount larger than max");

        uint256 destTokenAmountReceived;
        uint256 sourceTokenAmountUsed;

        uint256 tradingFee;
        if (!miscBool) { // bypassFee
            if (vals[2] == 0) {
                // condition: vals[0] will always be used as sourceAmount

                tradingFee = _getTradingFee(vals[0]);
                if (tradingFee != 0) {
                    _payTradingFee(
                        addrs[4], // user
                        loanId,
                        addrs[0], // sourceToken
                        tradingFee
                    );

                    vals[0] = vals[0]
                        .sub(tradingFee);
                }
            } else {
                // condition: unknown sourceAmount will be used

                tradingFee = _getTradingFee(vals[2]);

                if (tradingFee != 0) {
                    vals[2] = vals[2]
                        .add(tradingFee);
                }
            }
        }
        
        require(loanDataBytes.length == 0, "invalid state");

        (destTokenAmountReceived, sourceTokenAmountUsed) = _swapsCall_internal(
            addrs,
            vals
        );


        if (vals[2] == 0) {
            // there's no minimum destTokenAmount, but all of vals[0] (minSourceTokenAmount) must be spent
            require(sourceTokenAmountUsed == vals[0], "swap too large to fill");

            if (tradingFee != 0) {
                sourceTokenAmountUsed = sourceTokenAmountUsed
                    .add(tradingFee);
            }
        } else {
            // there's a minimum destTokenAmount required, but sourceTokenAmountUsed won't be greater than vals[1] (maxSourceTokenAmount)
            require(sourceTokenAmountUsed <= vals[1], "swap fill too large");
            require(destTokenAmountReceived >= vals[2], "insufficient swap liquidity");

            if (tradingFee != 0) {
                _payTradingFee(
                    addrs[4], // user
                    loanId, // loanId,
                    addrs[1], // destToken
                    tradingFee
                );

                destTokenAmountReceived = destTokenAmountReceived
                    .sub(tradingFee);
            }
        }

        return (destTokenAmountReceived, sourceTokenAmountUsed);
    }

    function _swapsCall_internal(
        address[5] memory addrs,
        uint256[3] memory vals)
        internal
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed)
    {
        bytes memory data = abi.encodeWithSelector(
            ISwapsImpl(swapsImpl).internalSwap.selector,
            addrs[0], // sourceToken
            addrs[1], // destToken
            addrs[2], // receiverAddress
            addrs[3], // returnToSenderAddress
            vals[0],  // minSourceTokenAmount
            vals[1],  // maxSourceTokenAmount
            vals[2]   // requiredDestTokenAmount
        );

        bool success;
        (success, data) = swapsImpl.delegatecall(data);
        require(success, "swap failed");

        assembly {
            destTokenAmountReceived := mload(add(data, 32))
            sourceTokenAmountUsed := mload(add(data, 64))
        }
    }

    function _swapsExpectedReturn(
        address sourceToken,
        address destToken,
        uint256 sourceTokenAmount)
        internal
        view
        returns (uint256)
    {
        uint256 tradingFee = _getTradingFee(sourceTokenAmount);
        if (tradingFee != 0) {
            sourceTokenAmount = sourceTokenAmount
                .sub(tradingFee);
        }

        uint256 sourceToDestRate = ISwapsImpl(swapsImpl).internalExpectedRate(
            sourceToken,
            destToken,
            sourceTokenAmount
        );
        uint256 sourceToDestPrecision = IPriceFeeds(priceFeeds).queryPrecision(
            sourceToken,
            destToken
        );

        return sourceTokenAmount
            .mul(sourceToDestRate)
            .div(sourceToDestPrecision);
    }

    function _checkSwapSize(
        address tokenAddress,
        uint256 amount)
        internal
        view
    {
        uint256 _maxSwapSize = maxSwapSize;
        if (_maxSwapSize != 0) {
            uint256 amountInEth;
            if (tokenAddress == address(wrbtcToken)) {
                amountInEth = amount;
            } else {
                amountInEth = IPriceFeeds(priceFeeds).amountInEth(tokenAddress, amount);
            }
            require(amountInEth <= _maxSwapSize, "swap too large");
        }
    }
}


// Dependency file: contracts/interfaces/ILoanPool.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

// pragma solidity >=0.5.0 <0.6.0;


interface ILoanPool {
    function tokenPrice()
        external
        view
        returns (uint256 price);

    function borrowInterestRate()
        external
        view
        returns (uint256);

    function totalAssetSupply()
        external
        view
        returns (uint256);
}


// Dependency file: contracts/mixins/RewardHelper.sol

// pragma solidity 0.5.17;

// import "contracts/core/State.sol";
// import "contracts/feeds/IPriceFeeds.sol";

contract RewardHelper is State {
    using SafeMath for uint256;

    /**
     * @dev returns base fee + flex fee
     */
    function _getRolloverReward(address collateralToken, address loanToken, uint256 positionSize)
        view
        internal
        returns (uint256 reward)
    {

        uint256 positionSizeInCollateralToken =
            IPriceFeeds(priceFeeds).queryReturn(loanToken, collateralToken, positionSize);
        uint256 rolloverBaseRewardInCollateralToken =
            IPriceFeeds(priceFeeds).queryReturn(address(wrbtcToken), collateralToken, rolloverBaseReward);

        return rolloverBaseRewardInCollateralToken.mul(2) // baseFee
                .add(positionSizeInCollateralToken.mul(rolloverFlexFeePercent).div(10 ** 20)); // flexFee = 0.1% of position size
    }
}


// Root file: contracts/modules/LoanClosings.sol

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

// import "contracts/core/State.sol";
// import "contracts/events/LoanClosingsEvents.sol";
// import "contracts/mixins/VaultController.sol";
// import "contracts/mixins/InterestUser.sol";
// import "contracts/mixins/LiquidationHelper.sol";
// import "contracts/swaps/SwapsUser.sol";
// import "contracts/interfaces/ILoanPool.sol";
// import "contracts/mixins/RewardHelper.sol";

contract LoanClosings is LoanClosingsEvents, VaultController, InterestUser, SwapsUser, LiquidationHelper, RewardHelper {
    uint256 constant internal MONTH = 365 days / 12;
    //0.00001 BTC, would be nicer in State.sol, but would require a redeploy of the complete protocol, so adding it here instead
    //because it's not shared state anyway and only used by this contract
    uint256 constant public paySwapExcessToBorrowerThreshold = 10000000000000;

    enum CloseTypes {
        Deposit,
        Swap,
        Liquidation
    }

    constructor() public {}

    function()
        external
    {
        revert("fallback not allowed");
    }

    function initialize(
        address target)
        external
        onlyOwner
    {
        _setTarget(this.liquidate.selector, target);
        _setTarget(this.rollover.selector, target);
        _setTarget(this.closeWithDeposit.selector, target);
        _setTarget(this.closeWithSwap.selector, target);
    }

    /**
     * liquidates a loan. the caller needs to approve the closeAmount prior to calling.
     * Will not liquidate more than is needed to restore the desired margin (maintenance +5%).
     * @param loanId the ID of the loan to liquidate
     * @param receiver the receiver of the seized amount
     * @param closeAmount the amount to close in loanTokens
     * */
    function liquidate(
        bytes32 loanId,
        address receiver,
        uint256 closeAmount) // denominated in loanToken
        external
        payable
        nonReentrant
        returns (
            uint256 loanCloseAmount,
            uint256 seizedAmount,
            address seizedToken
        )
    {
        return _liquidate(
            loanId,
            receiver,
            closeAmount
        );
    }

    function rollover(
        bytes32 loanId,
        bytes calldata /*loanDataBytes*/) // for future use
        external
        nonReentrant
    {
        // restrict to EOAs to prevent griefing attacks, during interest rate recalculation
        require(msg.sender == tx.origin, "only EOAs can call");

        return _rollover(
            loanId,
            "" // loanDataBytes
        );
    }

    /**
    * Closes a loan by doing a deposit
    * @param loanId the id of the loan
    * @param receiver the receiver of the remainder
    * @param depositAmount defines how much of the position should be closed. It is denominated in loan tokens.
    *       depositAmount > principal, the complete loan will be closed
    *       else deposit amount (partial closure)
    **/
    function closeWithDeposit(
        bytes32 loanId,
        address receiver,
        uint256 depositAmount) // denominated in loanToken
        public
        payable
        nonReentrant
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        )
    {
        return _closeWithDeposit(
            loanId,
            receiver,
            depositAmount
        );
    }

    /**
     * closes a position by swapping the collateral back to loan tokens, paying the lender
     * and withdrawing the remainder.
     * @param loanId the id of the loan
     * @param receiver the receiver of the remainder (unused collatral + profit)
     * @param swapAmount defines how much of the position should be closed and is denominated in collateral tokens.
     *      If swapAmount >= collateral, the complete position will be closed.
     *      Else if returnTokenIsCollateral, (swapAmount/collateral) * principal will be swapped (partial closure).
     *      Else coveredPrincipal
     * @param returnTokenIsCollateral defines if the remainder should be paid out in collateral tokens or underlying loan tokens
     * */
    function closeWithSwap(
        bytes32 loanId,
        address receiver,
        uint256 swapAmount, // denominated in collateralToken
        bool returnTokenIsCollateral, // true: withdraws collateralToken, false: withdraws loanToken
        bytes memory /*loanDataBytes*/) // for future use
        public
        nonReentrant
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        )
    {
        return _closeWithSwap(
            loanId,
            receiver,
            swapAmount,
            returnTokenIsCollateral,
            "" // loanDataBytes
        );
    }

    /**
     * internal function for liquidating a loan.
     * @param loanId the ID of the loan to liquidate
     * @param receiver the receiver of the seized amount
     * @param closeAmount the amount to close in loanTokens
     * */
    function _liquidate(
        bytes32 loanId,
        address receiver,
        uint256 closeAmount)
        internal
        returns (
            uint256 loanCloseAmount,
            uint256 seizedAmount,
            address seizedToken
        )
    {
        Loan storage loanLocal = loans[loanId];
        LoanParams storage loanParamsLocal = loanParams[loanLocal.loanParamsId];

        require(loanLocal.active, "loan is closed");
        require(loanParamsLocal.id != 0, "loanParams not exists");

        (uint256 currentMargin, uint256 collateralToLoanRate) = IPriceFeeds(priceFeeds).getCurrentMargin(
            loanParamsLocal.loanToken,
            loanParamsLocal.collateralToken,
            loanLocal.principal,
            loanLocal.collateral
        );
        require(
            currentMargin <= loanParamsLocal.maintenanceMargin,
            "healthy position"
        );

        loanCloseAmount = closeAmount;

        //amounts to restore the desired margin (maintencance + 5%)
        (uint256 maxLiquidatable, uint256 maxSeizable,) = _getLiquidationAmounts(
            loanLocal.principal,
            loanLocal.collateral,
            currentMargin,
            loanParamsLocal.maintenanceMargin,
            collateralToLoanRate
        );

        if (loanCloseAmount < maxLiquidatable) {
            seizedAmount = maxSeizable
                .mul(loanCloseAmount)
                .div(maxLiquidatable);
        } else if (loanCloseAmount > maxLiquidatable) {
            // adjust down the close amount to the max
            loanCloseAmount = maxLiquidatable;
            seizedAmount = maxSeizable;
        } else {
            seizedAmount = maxSeizable;
        }

        require(loanCloseAmount != 0, "nothing to liquidate");

        // liquidator deposits the principal being closed
        _returnPrincipalWithDeposit(
            loanParamsLocal.loanToken,
            address(this),
            loanCloseAmount
        );

        // a portion of the principal is repaid to the lender out of interest refunded
        uint256 loanCloseAmountLessInterest = _settleInterestToPrincipal(
            loanLocal,
            loanParamsLocal,
            loanCloseAmount,
            loanLocal.borrower
        );

        if (loanCloseAmount > loanCloseAmountLessInterest) {
            // full interest refund goes to the borrower
            _withdrawAsset(
                loanParamsLocal.loanToken,
                loanLocal.borrower,
                loanCloseAmount - loanCloseAmountLessInterest
            );
        }

        if (loanCloseAmountLessInterest != 0) {
            // The lender always gets back an ERC20 (even wrbtc), so we call withdraw directly rather than
            // use the _withdrawAsset helper function
            vaultWithdraw(
                loanParamsLocal.loanToken,
                loanLocal.lender,
                loanCloseAmountLessInterest
            );
        }

        seizedToken = loanParamsLocal.collateralToken;

        if (seizedAmount != 0) {
            loanLocal.collateral = loanLocal.collateral
                .sub(seizedAmount);

            _withdrawAsset(
                seizedToken,
                receiver,
                seizedAmount
            );
        }

        _closeLoan(
            loanLocal,
            loanCloseAmount
        );

        _emitClosingEvents(
            loanParamsLocal,
            loanLocal,
            loanCloseAmount,
            seizedAmount,
            collateralToLoanRate,
            0, // collateralToLoanSwapRate
            currentMargin,
            CloseTypes.Liquidation
        );
    }

    function _rollover(
        bytes32 loanId,
        bytes memory loanDataBytes)
        internal
    {
        Loan storage loanLocal = loans[loanId];
        LoanParams storage loanParamsLocal = loanParams[loanLocal.loanParamsId];

        require(loanLocal.active, "loan is closed");
        require(loanParamsLocal.id != 0, "loanParams not exists");
        require(
            block.timestamp > loanLocal.endTimestamp.sub(3600),
            "healthy position"
        );
        require(
            loanPoolToUnderlying[loanLocal.lender] != address(0),
            "invalid lender"
        );

        // pay outstanding interest to lender
        _payInterest(
            loanLocal.lender,
            loanParamsLocal.loanToken
        );

        LoanInterest storage loanInterestLocal = loanInterest[loanLocal.id];
        LenderInterest storage lenderInterestLocal = lenderInterest[loanLocal.lender][loanParamsLocal.loanToken];

        _settleFeeRewardForInterestExpense(
            loanInterestLocal,
            loanLocal.id,
            loanParamsLocal.loanToken,
            loanLocal.borrower,
            block.timestamp
        );

        // Handle back interest: calculates interest owned since the loan endtime passed but the loan remained open
        uint256 backInterestTime;
        uint256 backInterestOwed;
        if (block.timestamp > loanLocal.endTimestamp) {
            backInterestTime = block.timestamp
                .sub(loanLocal.endTimestamp);
            backInterestOwed = backInterestTime
                .mul(loanInterestLocal.owedPerDay);
            backInterestOwed = backInterestOwed
                .div(1 days);
        }

        //note: to avoid code duplication, it would be nicer to store loanParamsLocal.maxLoanTerm in a local variable
        //however, we've got stack too deep issues if we do so.
        if (loanParamsLocal.maxLoanTerm != 0) {
            // fixed-term loan, so need to query iToken for latest variable rate
            uint256 owedPerDay = loanLocal.principal
                .mul(ILoanPool(loanLocal.lender).borrowInterestRate())
                .div(365 * 10**20);

            lenderInterestLocal.owedPerDay = lenderInterestLocal.owedPerDay
                .add(owedPerDay);
            lenderInterestLocal.owedPerDay = lenderInterestLocal.owedPerDay
                .sub(loanInterestLocal.owedPerDay);

            loanInterestLocal.owedPerDay = owedPerDay;

            //if the loan has been open for longer than an additional period, add at least 1 additional day
            if (backInterestTime >= loanParamsLocal.maxLoanTerm) {
                loanLocal.endTimestamp = loanLocal.endTimestamp
                    .add(backInterestTime).add(1 days);
            }
            //extend by the max loan term
            else{
                loanLocal.endTimestamp = loanLocal.endTimestamp
                    .add(loanParamsLocal.maxLoanTerm);
            }
        } else {
            // loanInterestLocal.owedPerDay doesn't change
            if (backInterestTime >= MONTH){
                loanLocal.endTimestamp = loanLocal.endTimestamp
                    .add(backInterestTime).add(1 days);
            }
            else{
                loanLocal.endTimestamp = loanLocal.endTimestamp
                    .add(MONTH); 
            }
        }

        uint256 interestAmountRequired = loanLocal.endTimestamp
            .sub(block.timestamp);
        interestAmountRequired = interestAmountRequired
            .mul(loanInterestLocal.owedPerDay);
        interestAmountRequired = interestAmountRequired
            .div(1 days);

        loanInterestLocal.depositTotal = loanInterestLocal.depositTotal
            .add(interestAmountRequired);

        lenderInterestLocal.owedTotal = lenderInterestLocal.owedTotal
            .add(interestAmountRequired);

        // add backInterestOwed
        interestAmountRequired = interestAmountRequired
            .add(backInterestOwed);

        // collect interest (needs to be converted from the collateral)
        ( uint256 destTokenAmountReceived , uint256 sourceTokenAmountUsed,) = _doCollateralSwap(
            loanLocal,
            loanParamsLocal,
            0,//min swap 0 -> swap connector estimates the amount of source tokens to use
            interestAmountRequired,//required destination tokens
            true, // returnTokenIsCollateral
            loanDataBytes
        );

        //received more tokens than needed to pay the interest 
        if(destTokenAmountReceived > interestAmountRequired){
            // swap rest back to collateral, if the amount is big enough to cover gas cost
            if(worthTheTransfer(loanParamsLocal.loanToken, destTokenAmountReceived - interestAmountRequired)){
                (destTokenAmountReceived , ,) = _swapBackExcess(
                    loanLocal,
                    loanParamsLocal,
                    destTokenAmountReceived - interestAmountRequired,  //amount to be swapped
                    loanDataBytes);
                sourceTokenAmountUsed = sourceTokenAmountUsed.sub(destTokenAmountReceived);
            }
            //else give it to the protocol as a lending fee
            else{
                _payLendingFee(loanLocal.borrower, loanParamsLocal.loanToken, destTokenAmountReceived - interestAmountRequired);
            }
            
        }

        //subtract the interest from the collateral
        loanLocal.collateral = loanLocal.collateral
            .sub(sourceTokenAmountUsed);

        if (backInterestOwed != 0) {
            // pay out backInterestOwed

            _payInterestTransfer(
                loanLocal.lender,
                loanParamsLocal.loanToken,
                backInterestOwed
            );
        }

        uint256 rolloverReward = _getRolloverReward(loanParamsLocal.collateralToken, loanParamsLocal.loanToken, loanLocal.principal);

        if (rolloverReward != 0) {
            // pay out reward to caller
            loanLocal.collateral = loanLocal.collateral
                .sub(rolloverReward);

            _withdrawAsset(
                loanParamsLocal.collateralToken,
                msg.sender,
                rolloverReward
            );
        }

        (uint256 currentMargin,) = IPriceFeeds(priceFeeds).getCurrentMargin(
            loanParamsLocal.loanToken,
            loanParamsLocal.collateralToken,
            loanLocal.principal,
            loanLocal.collateral
        );
        require(
            currentMargin > 3 ether, // ensure there's more than 3% margin remaining
            "unhealthy position"
        );
    }

    /**
    * Internal function for closing a loan by doing a deposit
    * @param loanId the id of the loan
    * @param receiver the receiver of the remainder
    * @param depositAmount defines how much of the position should be closed. It is denominated in loan tokens.
    *       depositAmount > principal, the complete loan will be closed
    *       else deposit amount (partial closure)
    **/
    function _closeWithDeposit(
        bytes32 loanId,
        address receiver,
        uint256 depositAmount) // denominated in loanToken
        internal
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        )
    {
        require(depositAmount != 0, "depositAmount == 0");

        Loan storage loanLocal = loans[loanId];
        LoanParams storage loanParamsLocal = loanParams[loanLocal.loanParamsId];
        _checkAuthorized(
            loanLocal,
            loanParamsLocal
        );

        // can't close more than the full principal
        loanCloseAmount = depositAmount > loanLocal.principal ?
            loanLocal.principal :
            depositAmount;

        uint256 loanCloseAmountLessInterest = _settleInterestToPrincipal(
            loanLocal,
            loanParamsLocal,
            loanCloseAmount,
            receiver
        );

        if (loanCloseAmountLessInterest != 0) {
            _returnPrincipalWithDeposit(
                loanParamsLocal.loanToken,
                loanLocal.lender,
                loanCloseAmountLessInterest
            );
        }

        if (loanCloseAmount == loanLocal.principal) {
            withdrawAmount = loanLocal.collateral;
        } else {
            withdrawAmount = loanLocal.collateral
                .mul(loanCloseAmount)
                .div(loanLocal.principal);
        }

        withdrawToken = loanParamsLocal.collateralToken;

        if (withdrawAmount != 0) {
            loanLocal.collateral = loanLocal.collateral
                .sub(withdrawAmount);

            _withdrawAsset(
                withdrawToken,
                receiver,
                withdrawAmount
            );
        }

        _finalizeClose(
            loanLocal,
            loanParamsLocal,
            loanCloseAmount,
            withdrawAmount, // collateralCloseAmount
            0, // collateralToLoanSwapRate
            CloseTypes.Deposit
        );
    }

    /**
     * internal function for closing a position by swapping the collateral back to loan tokens, paying the lender
     * and withdrawing the remainder.
     * @param loanId the id of the loan
     * @param receiver the receiver of the remainder (unused collatral + profit)
     * @param swapAmount defines how much of the position should be closed and is denominated in collateral tokens.
     *      If swapAmount >= collateral, the complete position will be closed.
     *      Else if returnTokenIsCollateral, (swapAmount/collateral) * principal will be swapped (partial closure).
     *      Else coveredPrincipal
     * @param returnTokenIsCollateral defines if the remainder should be paid out in collateral tokens or underlying loan tokens
     * */
    function _closeWithSwap(
        bytes32 loanId,
        address receiver,
        uint256 swapAmount,
        bool returnTokenIsCollateral,
        bytes memory loanDataBytes)
        internal
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        )
    {
        require(swapAmount != 0, "swapAmount == 0");

        Loan storage loanLocal = loans[loanId];
        LoanParams storage loanParamsLocal = loanParams[loanLocal.loanParamsId];
        _checkAuthorized(
            loanLocal,
            loanParamsLocal
        );

        //can't swap more than collateral
        swapAmount = swapAmount > loanLocal.collateral ?
            loanLocal.collateral :
            swapAmount;

        uint256 loanCloseAmountLessInterest;
        if (swapAmount == loanLocal.collateral || returnTokenIsCollateral) {
            //loanCloseAmountLessInterest will be passed as required amount amount of destination tokens.
            //this means, the actual swapAmount passed to the swap contract does not matter at all.
            //the source token amount will be computed depending on the required amount amount of destination tokens.
            loanCloseAmount = swapAmount == loanLocal.collateral ?
                loanLocal.principal :
                loanLocal.principal
                    .mul(swapAmount)
                    .div(loanLocal.collateral);
            require(loanCloseAmount != 0, "loanCloseAmount == 0");
            
            //computes the interest refund for the borrower and sends it to the lender to cover part of the principal
            loanCloseAmountLessInterest = _settleInterestToPrincipal(
                loanLocal,
                loanParamsLocal,
                loanCloseAmount,
                receiver
            );
        } else {
            // loanCloseAmount is calculated after swap; for this case we want to swap the entire source amount
            // and determine the loanCloseAmount and withdraw amount based on that
            loanCloseAmountLessInterest = 0;
        }

        uint256 coveredPrincipal;
        uint256 usedCollateral;
        // swapAmount repurposed for collateralToLoanSwapRate to avoid stack too deep error
        (coveredPrincipal, usedCollateral, withdrawAmount, swapAmount) = _coverPrincipalWithSwap(
            loanLocal,
            loanParamsLocal,
            swapAmount, //the amount of source tokens to swap (only matters if !returnTokenIsCollateral or loanCloseAmountLessInterest = 0)
            loanCloseAmountLessInterest, //this is the amount of destination tokens we want to receive (only matters if returnTokenIsCollateral)
            returnTokenIsCollateral,
            loanDataBytes
        );

        if (loanCloseAmountLessInterest == 0) {
            // condition prior to swap: swapAmount != loanLocal.collateral && !returnTokenIsCollateral

            // amounts that is closed
            loanCloseAmount = coveredPrincipal;
            if (coveredPrincipal != loanLocal.principal) {
                loanCloseAmount = loanCloseAmount
                    .mul(usedCollateral)
                    .div(loanLocal.collateral);
            }
            require(loanCloseAmount != 0, "loanCloseAmount == 0");

            // amount that is returned to the lender
            loanCloseAmountLessInterest = _settleInterestToPrincipal(
                loanLocal,
                loanParamsLocal,
                loanCloseAmount,
                receiver
            );

            // remaining amount withdrawn to the receiver
            withdrawAmount = withdrawAmount
                .add(coveredPrincipal)
                .sub(loanCloseAmountLessInterest);
        } else {
            //pay back the amount which was covered by the swap
            loanCloseAmountLessInterest = coveredPrincipal;
        }

        require(loanCloseAmountLessInterest != 0, "closeAmount is 0 after swap");
        
        //reduce the collateral by the amount which was swapped for the closure
        if (usedCollateral != 0) {
            loanLocal.collateral = loanLocal.collateral
                .sub(usedCollateral);
        }

        // Repays principal to lender
        // The lender always gets back an ERC20 (even wrbtc), so we call withdraw directly rather than
        // use the _withdrawAsset helper function
        vaultWithdraw(
            loanParamsLocal.loanToken,
            loanLocal.lender,
            loanCloseAmountLessInterest
        );

        withdrawToken = returnTokenIsCollateral ?
            loanParamsLocal.collateralToken :
            loanParamsLocal.loanToken;

        if (withdrawAmount != 0) {
            _withdrawAsset(
                withdrawToken,
                receiver,
                withdrawAmount
            );
        }

        _finalizeClose(
            loanLocal,
            loanParamsLocal,
            loanCloseAmount,
            usedCollateral,
            swapAmount, // collateralToLoanSwapRate
            CloseTypes.Swap
        );
    }

    function _checkAuthorized(
        Loan memory loanLocal,
        LoanParams memory loanParamsLocal)
        internal
        view
    {
        require(loanLocal.active, "loan is closed");
        require(
            msg.sender == loanLocal.borrower ||
            delegatedManagers[loanLocal.id][msg.sender],
            "unauthorized"
        );
        require(loanParamsLocal.id != 0, "loanParams not exists");
    }
    
    /**
     * @dev computes the interest which needs to be refunded to the borrower based on the amount he's closing and either
     * subtracts it from the amount which still needs to be paid back (in case outstanding amount > interest) or withdraws the
     * excess to the borrower (in case interest > outstanding).
     * @param loanLocal the loan
     * @param loanParamsLocal the loan params
     * @param loanCloseAmount the amount to be closed (base for the computation)
     * @param receiver the address of the receiver (usually the borrower)
     * */
    function _settleInterestToPrincipal(
        Loan memory loanLocal,
        LoanParams memory loanParamsLocal,
        uint256 loanCloseAmount,
        address receiver)
        internal
        returns (uint256)
    {
        uint256 loanCloseAmountLessInterest = loanCloseAmount;

        //compute the interest which neeeds to be refunded to the borrower (because full interest is paid on loan )
        uint256 interestRefundToBorrower = _settleInterest(
            loanParamsLocal,
            loanLocal,
            loanCloseAmountLessInterest
        );

        uint256 interestAppliedToPrincipal;
        //if the outstanding loan is bigger than the interest to be refunded, reduce the amount to be paid back / closed by the interest
        if (loanCloseAmountLessInterest >= interestRefundToBorrower) {
            // apply all of borrower interest refund torwards principal
            interestAppliedToPrincipal = interestRefundToBorrower;

            // principal needed is reduced by this amount
            loanCloseAmountLessInterest -= interestRefundToBorrower;

            // no interest refund remaining
            interestRefundToBorrower = 0;
        } else {//if the interest refund is bigger than the outstanding loan, the user needs to get back the interest
            // principal fully covered by excess interest
            interestAppliedToPrincipal = loanCloseAmountLessInterest;

            // amount refunded is reduced by this amount
            interestRefundToBorrower -= loanCloseAmountLessInterest;

            // principal fully covered by excess interest
            loanCloseAmountLessInterest = 0;

            if (interestRefundToBorrower != 0) {
                // refund overage
                _withdrawAsset(
                    loanParamsLocal.loanToken,
                    receiver,
                    interestRefundToBorrower
                );
            }
        }

        //pay the interest to the lender
        //note: this is a waste of gas, because the loanCloseAmountLessInterest is withdrawn to the lender, too. It could be done at once.
        if (interestAppliedToPrincipal != 0) {
            // The lender always gets back an ERC20 (even wrbtc), so we call withdraw directly rather than
            // use the _withdrawAsset helper function
            vaultWithdraw(
                loanParamsLocal.loanToken,
                loanLocal.lender,
                interestAppliedToPrincipal
            );
        }

        return loanCloseAmountLessInterest;
    }

    // The receiver always gets back an ERC20 (even wrbtc)
    function _returnPrincipalWithDeposit(
        address loanToken,
        address receiver,
        uint256 principalNeeded)
        internal
    {
        if (principalNeeded != 0) {
            if (msg.value == 0) {
                vaultTransfer(
                    loanToken,
                    msg.sender,
                    receiver,
                    principalNeeded
                );
            } else {
                require(loanToken == address(wrbtcToken), "wrong asset sent");
                require(msg.value >= principalNeeded, "not enough ether");
                wrbtcToken.deposit.value(principalNeeded)();
                if (receiver != address(this)) {
                    vaultTransfer(
                        loanToken,
                        address(this),
                        receiver,
                        principalNeeded
                    );
                }
                if (msg.value > principalNeeded) {
                    // refund overage
                    Address.sendValue(
                        msg.sender,
                        msg.value - principalNeeded
                    );
                }
            }
        } else {
            require(msg.value == 0, "wrong asset sent");
        }
    }
    
    /**
     * @dev checks if the amount of the asset to be transfered is worth the transfer fee
     * @param asset the asset to be transfered
     * @param amount the amount to be transfered
     * @return True if the amount is bigger than the threshold
     * */
    function worthTheTransfer(address asset, uint256 amount) internal returns (bool){
        (uint256 rbtcRate, uint256 rbtcPrecision) = IPriceFeeds(priceFeeds).queryRate(asset, address(wrbtcToken));
        uint256 amountInRbtc = amount.mul(rbtcRate).div(rbtcPrecision);
        emit swapExcess(amountInRbtc > paySwapExcessToBorrowerThreshold, amount, amountInRbtc, paySwapExcessToBorrowerThreshold);
        return amountInRbtc > paySwapExcessToBorrowerThreshold;
    }
    

    /**
     * swaps a share of a loan's collateral or the complete collateral in order to cover the principle.
     * @param loanLocal the loan
     * @param loanParamsLocal the loan parameters
     * @param swapAmount in case principalNeeded == 0 or !returnTokenIsCollateral, this is the amount which is going to be swapped.
     *  Else, swapAmount doesn't matter, because the amount of source tokens needed for the swap is estimated by the connector.
     * @param principalNeeded the required amount of destination tokens in order to cover the principle (only used if returnTokenIsCollateral)
     * @param returnTokenIsCollateral tells if the user wants to withdraw his remaining collateral + profit in collateral tokens
     * */
    function _coverPrincipalWithSwap(
        Loan memory loanLocal,
        LoanParams memory loanParamsLocal,
        uint256 swapAmount,
        uint256 principalNeeded,
        bool returnTokenIsCollateral,
        bytes memory loanDataBytes)
        internal
        returns (uint256 coveredPrincipal, uint256 usedCollateral, uint256 withdrawAmount, uint256 collateralToLoanSwapRate)
    {
        uint256 destTokenAmountReceived;
        uint256 sourceTokenAmountUsed;
        (destTokenAmountReceived, sourceTokenAmountUsed, collateralToLoanSwapRate) = _doCollateralSwap(
            loanLocal,
            loanParamsLocal,
            swapAmount,
            principalNeeded,
            returnTokenIsCollateral,
            loanDataBytes
        );

        if (returnTokenIsCollateral) {
            coveredPrincipal = principalNeeded;
            
            // better fill than expected
            if (destTokenAmountReceived > coveredPrincipal) {

                //  send excess to borrower if the amount is big enough to be worth the gas fees
                if(worthTheTransfer(loanParamsLocal.loanToken, destTokenAmountReceived - coveredPrincipal)){
                    _withdrawAsset(
                        loanParamsLocal.loanToken,
                        loanLocal.borrower,
                        destTokenAmountReceived - coveredPrincipal
                    );
                }
                // else, give the excess to the lender (if it goes to the borrower, they're very confused. causes more trouble than it's worth)
                else{
                    coveredPrincipal = destTokenAmountReceived;
                }
                
            }
            withdrawAmount = swapAmount > sourceTokenAmountUsed ?
                swapAmount - sourceTokenAmountUsed :
                0;
        } else {
            require(sourceTokenAmountUsed == swapAmount, "swap error");

            if (swapAmount == loanLocal.collateral) {
                // sourceTokenAmountUsed == swapAmount == loanLocal.collateral

                coveredPrincipal = principalNeeded;
                withdrawAmount = destTokenAmountReceived - principalNeeded;

            } else {
                // sourceTokenAmountUsed == swapAmount < loanLocal.collateral

                if (destTokenAmountReceived >= loanLocal.principal) {
                    // edge case where swap covers full principal

                    coveredPrincipal = loanLocal.principal;
                    withdrawAmount = destTokenAmountReceived - loanLocal.principal;

                    // excess collateral refunds to the borrower
                    _withdrawAsset(
                        loanParamsLocal.collateralToken,
                        loanLocal.borrower,
                        loanLocal.collateral - sourceTokenAmountUsed
                    );
                    sourceTokenAmountUsed = loanLocal.collateral;
                } else {
                    coveredPrincipal = destTokenAmountReceived;
                    withdrawAmount = 0;
                }
            }
        }

        usedCollateral = sourceTokenAmountUsed > swapAmount ?
            sourceTokenAmountUsed :
            swapAmount;
    }

    /**
     * swaps collateral tokens for loan tokens
     * @param loanLocal the loan object
     * @param loanParamsLocal the loan parameters
     * @param swapAmount the amount to be swapped
     * @param principalNeeded the required destination token amount
     * @param returnTokenIsCollateral if true -> required destination token amount will be passed on, else not
     *          note: quite dirty. should be refactored.
     * @param loanDataBytes additional loan data (not in use for token swaps)
     * */
    function _doCollateralSwap(
        Loan memory loanLocal,
        LoanParams memory loanParamsLocal,
        uint256 swapAmount,
        uint256 principalNeeded,
        bool returnTokenIsCollateral,
        bytes memory loanDataBytes)
        internal
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed, uint256 collateralToLoanSwapRate)
    {
        (destTokenAmountReceived, sourceTokenAmountUsed, collateralToLoanSwapRate) = _loanSwap(
            loanLocal.id,
            loanParamsLocal.collateralToken,
            loanParamsLocal.loanToken,
            loanLocal.borrower,
            swapAmount, // minSourceTokenAmount
            loanLocal.collateral, // maxSourceTokenAmount
            returnTokenIsCollateral ?
                principalNeeded :  // requiredDestTokenAmount
                0,
            false, // bypassFee
            loanDataBytes
        );
        require(destTokenAmountReceived >= principalNeeded, "insufficient dest amount");
        require(sourceTokenAmountUsed <= loanLocal.collateral, "excessive source amount");
    }

    /**
     * used to swap back excessive loan tokens to collateral tokens.
     * @param loanLocal the loan object
     * @param loanParamsLocal the loan parameters
     * @param swapAmount the amount to be swapped
     * @param loanDataBytes additional loan data (not in use for token swaps)
     * */
    function _swapBackExcess(
        Loan memory loanLocal,
        LoanParams memory loanParamsLocal,
        uint256 swapAmount,
        bytes memory loanDataBytes)
        internal
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed, uint256 collateralToLoanSwapRate)
    {
        (destTokenAmountReceived, sourceTokenAmountUsed, collateralToLoanSwapRate) = _loanSwap(
            loanLocal.id,
            loanParamsLocal.loanToken,
            loanParamsLocal.collateralToken,
            loanLocal.borrower,
            swapAmount, // minSourceTokenAmount
            swapAmount, // maxSourceTokenAmount
            0,  // requiredDestTokenAmount
            false, // bypassFee
            loanDataBytes
        );
        require(sourceTokenAmountUsed <= swapAmount, "excessive source amount");
    }


    // withdraws asset to receiver
    function _withdrawAsset(
        address assetToken,
        address receiver,
        uint256 assetAmount)
        internal
    {
        if (assetAmount != 0) {
            if (assetToken == address(wrbtcToken)) {
                vaultEtherWithdraw(
                    receiver,
                    assetAmount
                );
            } else {
                vaultWithdraw(
                    assetToken,
                    receiver,
                    assetAmount
                );
            }
        }
    }

    function _finalizeClose(
        Loan storage loanLocal,
        LoanParams storage loanParamsLocal,
        uint256 loanCloseAmount,
        uint256 collateralCloseAmount,
        uint256 collateralToLoanSwapRate,
        CloseTypes closeType)
        internal
    {
        _closeLoan(
            loanLocal,
            loanCloseAmount
        );

        address _priceFeeds = priceFeeds;
        uint256 currentMargin;
        uint256 collateralToLoanRate;

        // this is still called even with full loan close to return collateralToLoanRate
        (bool success, bytes memory data) = _priceFeeds.staticcall(
            abi.encodeWithSelector(
                IPriceFeeds(_priceFeeds).getCurrentMargin.selector,
                loanParamsLocal.loanToken,
                loanParamsLocal.collateralToken,
                loanLocal.principal,
                loanLocal.collateral
            )
        );
        assembly {
            if eq(success, 1) {
                currentMargin := mload(add(data, 32))
                collateralToLoanRate := mload(add(data, 64))
            }
        }
        //// Note: We can safely skip the margin check if closing via closeWithDeposit or if closing the loan in full by any method ////
        require(
            closeType == CloseTypes.Deposit ||
            loanLocal.principal == 0 || // loan fully closed
            currentMargin > loanParamsLocal.maintenanceMargin,
            "unhealthy position"
        );

        _emitClosingEvents(
            loanParamsLocal,
            loanLocal,
            loanCloseAmount,
            collateralCloseAmount,
            collateralToLoanRate,
            collateralToLoanSwapRate,
            currentMargin,
            closeType
        );
    }

    function _closeLoan(
        Loan storage loanLocal,
        uint256 loanCloseAmount)
        internal
        returns (uint256)
    {
        require(loanCloseAmount != 0, "nothing to close");

        if (loanCloseAmount == loanLocal.principal) {
            loanLocal.principal = 0;
            loanLocal.active = false;
            loanLocal.endTimestamp = block.timestamp;
            loanLocal.pendingTradesId = 0;
            activeLoansSet.removeBytes32(loanLocal.id);
            lenderLoanSets[loanLocal.lender].removeBytes32(loanLocal.id);
            borrowerLoanSets[loanLocal.borrower].removeBytes32(loanLocal.id);
        } else {
            loanLocal.principal = loanLocal.principal
                .sub(loanCloseAmount);
        }
    }

    function _settleInterest(
        LoanParams memory loanParamsLocal,
        Loan memory loanLocal,
        uint256 closePrincipal)
        internal
        returns (uint256)
    {
        // pay outstanding interest to lender
        _payInterest(
            loanLocal.lender,
            loanParamsLocal.loanToken
        );

        LoanInterest storage loanInterestLocal = loanInterest[loanLocal.id];
        LenderInterest storage lenderInterestLocal = lenderInterest[loanLocal.lender][loanParamsLocal.loanToken];

        uint256 interestTime = block.timestamp;
        if (interestTime > loanLocal.endTimestamp) {
            interestTime = loanLocal.endTimestamp;
        }

        _settleFeeRewardForInterestExpense(
            loanInterestLocal,
            loanLocal.id,
            loanParamsLocal.loanToken,
            loanLocal.borrower,
            interestTime
        );

        uint256 owedPerDayRefund;
        if (closePrincipal < loanLocal.principal) {
            owedPerDayRefund = loanInterestLocal.owedPerDay
                .mul(closePrincipal)
                .div(loanLocal.principal);
        } else {
            owedPerDayRefund = loanInterestLocal.owedPerDay;
        }

        // update stored owedPerDay
        loanInterestLocal.owedPerDay = loanInterestLocal.owedPerDay
            .sub(owedPerDayRefund);
        lenderInterestLocal.owedPerDay = lenderInterestLocal.owedPerDay
            .sub(owedPerDayRefund);

        // update borrower interest
        uint256 interestRefundToBorrower = loanLocal.endTimestamp
            .sub(interestTime);
        interestRefundToBorrower = interestRefundToBorrower
            .mul(owedPerDayRefund);
        interestRefundToBorrower = interestRefundToBorrower
            .div(1 days);

        if (closePrincipal < loanLocal.principal) {
            loanInterestLocal.depositTotal = loanInterestLocal.depositTotal
                .sub(interestRefundToBorrower);
        } else {
            loanInterestLocal.depositTotal = 0;
        }

        // update remaining lender interest values
        lenderInterestLocal.principalTotal = lenderInterestLocal.principalTotal
            .sub(closePrincipal);

        uint256 owedTotal = lenderInterestLocal.owedTotal;
        lenderInterestLocal.owedTotal = owedTotal > interestRefundToBorrower ?
            owedTotal - interestRefundToBorrower :
            0;

        return interestRefundToBorrower;
    }

    function _emitClosingEvents(
        LoanParams memory loanParamsLocal,
        Loan memory loanLocal,
        uint256 loanCloseAmount,
        uint256 collateralCloseAmount,
        uint256 collateralToLoanRate,
        uint256 collateralToLoanSwapRate,
        uint256 currentMargin,
        CloseTypes closeType)
        internal
    {
        if (closeType == CloseTypes.Deposit) {
            emit CloseWithDeposit(
                loanLocal.borrower,                             // user (borrower)
                loanLocal.lender,                               // lender
                loanLocal.id,                                   // loanId
                msg.sender,                                     // closer
                loanParamsLocal.loanToken,                      // loanToken
                loanParamsLocal.collateralToken,                // collateralToken
                loanCloseAmount,                                // loanCloseAmount
                collateralCloseAmount,                          // collateralCloseAmount
                collateralToLoanRate,                           // collateralToLoanRate
                currentMargin                                   // currentMargin
            );
        } else if (closeType == CloseTypes.Swap) {
            // exitPrice = 1 / collateralToLoanSwapRate
            if (collateralToLoanSwapRate != 0) {
                collateralToLoanSwapRate = SafeMath.div(10**36, collateralToLoanSwapRate);
            }

            // currentLeverage = 100 / currentMargin
            if (currentMargin != 0) {
                currentMargin = SafeMath.div(10**38, currentMargin);
            }

            emit CloseWithSwap(
                loanLocal.borrower,                             // user (trader)
                loanLocal.lender,                               // lender
                loanLocal.id,                                   // loanId
                loanParamsLocal.collateralToken,                // collateralToken
                loanParamsLocal.loanToken,                      // loanToken
                msg.sender,                                     // closer
                collateralCloseAmount,                          // positionCloseSize
                loanCloseAmount,                                // loanCloseAmount
                collateralToLoanSwapRate,                       // exitPrice (1 / collateralToLoanSwapRate)
                currentMargin                                   // currentLeverage
            );
        } else { // closeType == CloseTypes.Liquidation
            emit Liquidate(
                loanLocal.borrower,                             // user (borrower)
                msg.sender,                                     // liquidator
                loanLocal.id,                                   // loanId
                loanLocal.lender,                               // lender
                loanParamsLocal.loanToken,                      // loanToken
                loanParamsLocal.collateralToken,                // collateralToken
                loanCloseAmount,                                // loanCloseAmount
                collateralCloseAmount,                          // collateralCloseAmount
                collateralToLoanRate,                           // collateralToLoanRate
                currentMargin                                   // currentMargin
            );
        }
    }
}
