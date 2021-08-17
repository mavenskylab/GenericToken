// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./token/BEP20/BEP20.sol";
import "./math/SafeMath.sol";
import "./utils/Address.sol";

contract LanaCakeToken is BEP20 {
    using SafeMath for uint256;
    using Address for address;

    uint256 private toMint = 10000000 * 10**18;

    uint256 public maxTranscationAmount = toMint;
    uint256 public maxWalletToken = toMint;

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxSellTFransactionAmount;

    mapping(address => bool) _blacklist;

    event BlacklistUpdated(address indexed user, bool value);

    constructor() BEP20("GenericToken", "GTKN") {
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), toMint);
    }

    receive() external payable {}

    function setMaxTransaction(uint256 maxTx) external onlyOwner {
        maxTranscationAmount = maxTx * (10**18);
    }

    function setMaxWalletToken(uint256 maxTx) external onlyOwner {
        maxWalletToken = maxTx * (10**18);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(
            !isBlackListed(recipient),
            "Token transfer refused. Receiver is on blacklist"
        );

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        super._beforeTokenTransfer(sender, recipient, amount);

        require(
            amount <= maxTranscationAmount,
            "GenericToken: Transfer amount exceeds the maxTxAmount."
        );
        uint256 contractBalanceRecepient = balanceOf(recipient);
        require(
            contractBalanceRecepient + amount <= maxWalletToken,
            "GenericToken: Exceeds maximum wallet token amount."
        );

        super._transfer(sender, recipient, amount);
    }

    function isBlackListed(address user) public view returns (bool) {
        return _blacklist[user];
    }

    function blacklistUpdate(address user, bool value)
        public
        virtual
        onlyOwner
    {
        _blacklist[user] = value;
    }
}
