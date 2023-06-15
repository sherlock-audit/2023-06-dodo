// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import {InitializableOwnable} from "../../lib/InitializableOwnable.sol";
import {IERC20} from "../../../intf/IERC20.sol";
import {ID3UserQuota} from "../../intf/ID3UserQuota.sol";
import {ID3Vault} from "../../intf/ID3Vault.sol";
import "../../../intf/ID3Oracle.sol";
import "../../lib/DecimalMath.sol";


/// @title UserQuota
/// @notice This contract is used to set/get user's quota, i.e., determine the amount of token user can deposit into the pool.
contract D3UserQuota is InitializableOwnable, ID3UserQuota {
    using DecimalMath for uint256;

    // hold token dodo or vdodo or other
    address public _QUOTA_TOKEN_HOLD;
    // Threshold Amount [100,200,300,400]
    uint256[] public quotaTokenHoldAmount;
    //threshold quota amount
    uint256[] public quotaTokenAmount;
    // token => bool Deposit quota limit is not enabled.
    mapping(address => bool) public isUsingQuota;
    // token => bool Is the global deposit quota limit enabled
    mapping(address => bool) public isGlobalQuota;
    // token => quota The default global deposit quota is in USD.
    mapping(address => uint256) public gloablQuota;

    ID3Vault public d3Vault;

    constructor(address quotaTokenHold, address d3VaultAddress) {
        initOwner(msg.sender);
        _QUOTA_TOKEN_HOLD = quotaTokenHold;
        d3Vault = ID3Vault(d3VaultAddress);
    }

    /// @notice Enable quota for a token
    function enableQuota(address token, bool status) external onlyOwner {
        isUsingQuota[token] = status;
    }

    /// @notice Enable global quota for a token
    function enableGlobalQuota(address token, bool status) external onlyOwner {
        isGlobalQuota[token] = status;
    }

    /// @notice Set global quota for a token
    /// @notice Global quota means every user has the same quota
    function setGlobalQuota(address token, uint256 amount) external onlyOwner {
        gloablQuota[token] = amount;
    }
    // @notice Token address, holding that token is required to have a quota
    function setQuotaTokenHold(address quotaTokenHold) external onlyOwner {
        _QUOTA_TOKEN_HOLD = quotaTokenHold;
    }

    /// @notice Set the amount of tokens held and their corresponding quotas
    function setQuotaTokennAmount(
        uint256[] calldata _quotaTokenHoldAmount,
        uint256[] calldata _quotaTokenAmount
    ) external onlyOwner {
        require(_quotaTokenHoldAmount.length > 0 && _quotaTokenHoldAmount.length == _quotaTokenAmount.length, "D3UserQuota: length not match");
        quotaTokenHoldAmount = _quotaTokenHoldAmount;
        quotaTokenAmount = _quotaTokenAmount;
    }

    /// @notice Get the user quota for a token
    function getUserQuota(address user, address token) public view override returns (uint256) {
        //Query used quota
        //tokenlist useraddress get user usd quota
        uint256 usedQuota = 0;
        uint8 tokenDecimals = IERC20(token).decimals();
        address[] memory tokenList = d3Vault.getTokenList();
        for (uint256 i = 0; i < tokenList.length; i++) {
            address _token = tokenList[i];
            (address assetDToken,,,,,,,,,,) = d3Vault.getAssetInfo(_token);
            uint256 tokenBalance = IERC20(assetDToken).balanceOf(user);
            if (tokenBalance > 0) {
                tokenBalance = tokenBalance.mul(d3Vault.getExchangeRate(token));
                (uint256 tokenPrice, uint8 priceDecimal) = ID3Oracle(d3Vault._ORACLE_()).getOriginalPrice(_token);
                usedQuota = usedQuota + tokenBalance * tokenPrice / 10 ** (priceDecimal+tokenDecimals);
            }
        }
        //token price reduction
        (uint256 _tokenPrice, uint8 _priceDecimal) = ID3Oracle(d3Vault._ORACLE_()).getOriginalPrice(token);
        //calculate quota
        if (isUsingQuota[token]) {
            if (isGlobalQuota[token]) {
                return (gloablQuota[token] - usedQuota) * 10 ** (_priceDecimal + tokenDecimals) / _tokenPrice;
            } else {
                return (calculateQuota(user) - usedQuota) * 10 ** (_priceDecimal + tokenDecimals) / _tokenPrice;
            }
        } else {
            return type(uint256).max;
        }
    }
    /// @notice Check if the quantity of tokens deposited by the user is allowed.
    function checkQuota(address user, address token, uint256 amount) public view override returns (bool) {
        return (amount <= getUserQuota(user, token));
    }

    /// @notice Get the user quota for a token 100[10] 200[20]
    function calculateQuota(address user) public view returns (uint256 quota) {
        uint256 tokenBalance = IERC20(_QUOTA_TOKEN_HOLD).balanceOf(user);
        for (uint256 i = 0; i < quotaTokenHoldAmount.length; i++) {
            if (tokenBalance < quotaTokenHoldAmount[i]) {
                return quota = quotaTokenAmount[i];
            }
        }
        quota = quotaTokenAmount[quotaTokenAmount.length - 1];
    }
}
