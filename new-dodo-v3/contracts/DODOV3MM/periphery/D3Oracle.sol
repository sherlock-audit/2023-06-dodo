// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

import {InitializableOwnable} from "../lib/InitializableOwnable.sol";
import {ID3Oracle} from "../../intf/ID3Oracle.sol";
import "../lib/DecimalMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

struct PriceSource {
    address oracle;
    bool isWhitelisted;
    uint256 priceTolerance;
    uint8 priceDecimal;
    uint8 tokenDecimal;
    uint256 heartBeat;
}

contract D3Oracle is ID3Oracle, InitializableOwnable {
    // originToken => priceSource
    mapping(address => PriceSource) public priceSources;

    /// @notice Onwer is set in constructor
    constructor() {
        initOwner(msg.sender);
    }

    /// @notice Set the price source for a token
    /// @param token The token address
    /// @param source The price source for the token
    function setPriceSource(address token, PriceSource calldata source) external onlyOwner {
        priceSources[token] = source;
        require(source.priceTolerance <= DecimalMath.ONE && source.priceTolerance >= 1e10, "INVALID_PRICE_TOLERANCE");
    }

    /// @notice Enable or disable oracle for a token
    /// @dev Owner could stop oracle feed price in emergency
    /// @param token The token address
    /// @param isAvailable Whether the oracle is available for the token
    function setTokenOracleFeasible(address token, bool isAvailable) external onlyOwner {
        priceSources[token].isWhitelisted = isAvailable;
    }

    /// @notice Get the price for a token
    /// @dev The price definition is: how much virtual USD the token values if token amount is 1e18.
    /// @dev Example 1: if the token decimals is 18, and worth 2 USD, then price is 2e18.
    /// @dev Example 2: if the token decimals is 8, and worth 2 USD, then price is 2e28.
    /// @param token The token address
    function getPrice(address token) public view override returns (uint256) {
        require(priceSources[token].isWhitelisted, "INVALID_TOKEN");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceSources[token].oracle);
        (uint80 roundID, int256 price,, uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        require(price > 0, "Chainlink: Incorrect Price");
        require(block.timestamp - updatedAt < priceSources[token].heartBeat, "Chainlink: Stale Price");
        require(answeredInRound >= roundID, "Chainlink: Stale Price");
        return uint256(price) * 10 ** (36 - priceSources[token].priceDecimal - priceSources[token].tokenDecimal);
    }

    function getOriginalPrice(address token) public view override returns (uint256, uint8) {
        require(priceSources[token].isWhitelisted, "INVALID_TOKEN");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceSources[token].oracle);
        (uint80 roundID, int256 price,, uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        require(price > 0, "Chainlink: Incorrect Price");
        require(block.timestamp - updatedAt < priceSources[token].heartBeat, "Chainlink: Stale Price");
        require(answeredInRound >= roundID, "Chainlink: Stale Price");
        uint8 priceDecimal = priceSources[token].priceDecimal;
        return (uint256(price), priceDecimal);
    }

    /// @notice Return if oracle is feasible for a token
    /// @param token The token address
    function isFeasible(address token) external view override returns (bool) {
        return priceSources[token].isWhitelisted;
    }

    /// @notice Given certain amount of fromToken, get the max return amount of toToken
    /// @param fromToken The from token address
    /// @param toToken The to token address
    /// @param fromAmount The from token amount
    function getMaxReceive(address fromToken, address toToken, uint256 fromAmount) external view returns (uint256) {
        uint256 fromTlr = priceSources[fromToken].priceTolerance;
        uint256 toTlr = priceSources[toToken].priceTolerance;

        return DecimalMath.div((fromAmount * getPrice(fromToken)) / getPrice(toToken), DecimalMath.mul(fromTlr, toTlr));
    }
}
