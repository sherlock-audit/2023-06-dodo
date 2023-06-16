/*

    Copyright 2023 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../../TestContext.t.sol";
import "mock/MockD3Pool.sol";
import {Types} from "contracts/DODOV3MM/lib/Types.sol";
import {D3Maker} from "D3Pool/D3Maker.sol";

contract D3TradingTest is TestContext {
    MockERC20 public tokenEx;
    MockChainlinkPriceFeed public tokenExChainLinkOracle;

    struct SwapCallbackData {
        bytes data;
        address payer;
    }

    function setUp() public {
        contextBasic();
        setVaultAsset();
        setPoolAsset();
    }

    function testReadFunctions() public {
        (uint256 askDownPrice, uint256 askUpPrice, uint256 bidDownPrice, uint256 bidUpPrice, uint256 swapFee) =
            d3MM.getTokenMMPriceInfoForRead(address(token2));
        assertEq(askDownPrice, 12009600000000000000);
        assertEq(askUpPrice, 12027600000000000000);
        assertEq(bidDownPrice, 83400053376034161);
        assertEq(bidUpPrice, 83458521115005843);
        assertEq(swapFee, 800000000000000);

        //console.log(askDownPrice);
        //console.log(askUpPrice);
        //console.log(bidDownPrice);
        //console.log(bidUpPrice);
        //console.log(swapFee);

        (uint256 askAmount, uint256 bidAmount, uint256 kAsk, uint256 kBid, uint256 cumulativeAsk, uint256 cumulativeBid)
        = d3MM.getTokenMMOtherInfoForRead(address(token2));
        assertEq(askAmount, 30 * 1e18);
        assertEq(bidAmount, 30 * 1e18);
        assertEq(kAsk, 1e17);
        assertEq(kBid, 1e17);
        assertEq(cumulativeAsk, 0);
        assertEq(cumulativeBid, 0);
    }

    function testNormalSellTokens() public {
        uint256 beforeBalance2 = token2.balanceOf(user1);
        uint256 beforeBalance3 = token3.balanceOf(user1);

        SwapCallbackData memory swapData;
        swapData.data = "";
        swapData.payer = user1;

        uint256 gasleft1 = gasleft();
        uint256 receiveToToken = d3Proxy.sellTokens(
            address(d3MM),
            user1,
            address(token2),
            address(token3),
            1 ether,
            0,
            abi.encode(swapData),
            block.timestamp + 1000
        );
        uint256 gasleft2 = gasleft();
        console.log("sellToken1stTime gas\t", gasleft1 - gasleft2);

        uint256 afterBalance2 = token2.balanceOf(user1);
        uint256 afterBalance3 = token3.balanceOf(user1);

        //console.log(receiveToToken);
        assertEq(beforeBalance2 - afterBalance2, 1 ether);
        assertEq(afterBalance3 - beforeBalance3, receiveToToken);
        assertEq(afterBalance3 - beforeBalance3, 11959881980233813532);
    }

    function testNormalBuyTokens() public {
        uint256 beforeBalance2 = token2.balanceOf(user1);
        uint256 beforeBalance3 = token3.balanceOf(user1);

        SwapCallbackData memory swapData;
        swapData.data = "";
        swapData.payer = user1;

        uint256 gasleft1 = gasleft();
        uint256 receiveToToken = d3Proxy.buyTokens(
            address(d3MM),
            user1,
            address(token2),
            address(token3),
            1 ether,
            30 ether,
            abi.encode(swapData),
            block.timestamp + 1000
        );
        uint256 gasleft2 = gasleft();
        console.log("buyToken1stTime gas\t", gasleft1 - gasleft2);

        uint256 afterBalance2 = token2.balanceOf(user1);
        uint256 afterBalance3 = token3.balanceOf(user1);

        //console.log(beforeBalance2 - afterBalance2);
        //console.log(afterBalance3 - beforeBalance3);

        assertEq(beforeBalance2 - afterBalance2, receiveToToken);
        assertEq(beforeBalance2 - afterBalance2, 83601350012314569); // 0.08
        assertEq(afterBalance3 - beforeBalance3, 1 ether);
    }

    function testTransferInNotEnough() public {
        vm.startPrank(user1);
        token2.approve(address(dodoApprove), 10**14);
        token3.approve(address(dodoApprove), 10**17);
        vm.stopPrank();

        SwapCallbackData memory swapData;
        swapData.data = "";
        swapData.payer = user1;

        // approve not enough
        vm.expectRevert();
        uint256 receiveToToken = d3Proxy.buyTokens(
            address(d3MM),
            user1, 
            address(token2), 
            address(token3), 
            1 ether, 
            13 ether, 
            abi.encode(swapData),
            block.timestamp + 1000
        );

        vm.expectRevert();
        receiveToToken = d3Proxy.sellTokens(
            address(d3MM),
            user1, 
            address(token2), 
            address(token3), 
            1 ether, 
            0, 
            abi.encode(swapData),
            block.timestamp + 1000
        );

        // d3mm balance not enough
        faucetToken(address(token2), address(d3MM), 10 ** 14);
        vm.expectRevert(bytes("D3MM_FROMAMOUNT_NOT_ENOUGH"));
        receiveToToken = failD3Proxy.buyTokens(
            address(d3MM),
            user1, 
            address(token2), 
            address(token3), 
            1 ether, 
            13 ether, 
            abi.encode(swapData),
            block.timestamp + 1000
        );

        faucetToken(address(token2), address(d3MM), 10 ** 17);
        vm.expectRevert(bytes("D3MM_FROMAMOUNT_NOT_ENOUGH"));
        receiveToToken = failD3Proxy.sellTokens(
            address(d3MM),
            user1, 
            address(token2), 
            address(token3), 
            1 ether, 
            0, 
            abi.encode(swapData),
            block.timestamp + 1000
        );

        // success test

        uint256 beforeBalance2 = token2.balanceOf(user1);
        uint256 beforeBalance3 = token3.balanceOf(user1);
        (, , , , , uint256 cumulativeBid)
        = d3MM.getTokenMMOtherInfoForRead(address(token2));
        assertEq(cumulativeBid, 0);

        receiveToToken = failD3Proxy.buyTokens(
            address(d3MM),
            user1, 
            address(token2), 
            address(token3), 
            1 ether, 
            13 ether, 
            abi.encode(swapData),
            block.timestamp + 1000
        );

        uint256 afterBalance2 = token2.balanceOf(user1);
        uint256 afterBalance3 = token3.balanceOf(user1);

        assertEq(beforeBalance2 - afterBalance2, 1000); 
        assertEq(afterBalance3 - beforeBalance3, 1000000000000000000);

        (, , , , , cumulativeBid)
        = d3MM.getTokenMMOtherInfoForRead(address(token2));
        assertEq(cumulativeBid, 1002401946807995096); // 1.002 suppose 1 vusd
        //console.log("cumualativeBid:", cumulativeBid);

        beforeBalance2 = afterBalance2;
        beforeBalance3 = afterBalance3;

        faucetToken(address(token2), address(d3MM), 10 ** 18);
        receiveToToken = failD3Proxy.sellTokens(
            address(d3MM),
            user1, 
            address(token2), 
            address(token3), 
            1 ether, 
            0, 
            abi.encode(swapData),
            block.timestamp + 1000
        );

        afterBalance2 = token2.balanceOf(user1);
        afterBalance3 = token3.balanceOf(user1);

        //console.log(receiveToToken);
        assertEq(beforeBalance2 - afterBalance2, 1000); 
        assertEq(afterBalance3 - beforeBalance3, receiveToToken);
        assertEq(afterBalance3 - beforeBalance3, 11959586831563309114); // suppose 12
    }

    function testMinMaxRevert() public {
        SwapCallbackData memory swapData;
        swapData.data = "";
        swapData.payer = user1;

        vm.expectRevert(bytes("D3MM_MAXPAYAMOUNT_NOT_ENOUGH"));
        uint256 receiveToToken = d3Proxy.buyTokens(
            address(d3MM),
            user1,
            address(token2),
            address(token3),
            1 ether,
            0.02 ether,
            abi.encode(swapData),
            block.timestamp + 1000
        );

        vm.expectRevert(bytes("D3MM_MINRESERVE_NOT_ENOUGH"));
        receiveToToken = d3Proxy.sellTokens(
            address(d3MM),
            user1,
            address(token2),
            address(token3),
            1 ether,
            13 ether,
            abi.encode(swapData),
            block.timestamp + 1000
        );
    }

    function testHeartBeatFail() public {
        vm.warp(1000001);

        SwapCallbackData memory swapData;
        swapData.data = "";
        swapData.payer = user1;

        vm.expectRevert(bytes("D3MM_HEARTBEAT_CHECK_FAIL"));
        d3Proxy.buyTokens(
            address(d3MM),
            user1,
            address(token2),
            address(token3),
            1 ether,
            12 ether,
            abi.encode(swapData),
            block.timestamp + 1000
        );
    }

    function testBelowIM() public {
        vm.startPrank(poolCreator);
        d3MM.makerWithdraw(poolCreator, address(token1), 100 * 1e8);
        d3MM.makerWithdraw(poolCreator, address(token2), 96 * 1e18);
        d3MM.makerWithdraw(poolCreator, address(token3), 100 * 1e18);
        d3MM.borrow(address(token2), 9 * 1e18);
        vm.stopPrank();

        // change token2 amount
        uint64 newAmount = stickAmount(4000, 18, 4000, 18);
        uint64[] memory amounts = new uint64[](1);
        amounts[0] = newAmount;
        address[] memory tokens = new address[](1);
        tokens[0] = address(token2);
        vm.prank(maker);
        d3MakerWithPool.setTokensAmounts(tokens, amounts);

        // create and set tokenEx oracle
        tokenEx = new MockERC20("TokenEx", "TKEx", 18);
        tokenExChainLinkOracle = new MockChainlinkPriceFeed("TokenEx/USD", 18);
        tokenExChainLinkOracle.feedData(24 * 1e18);
        oracle.setPriceSource(
            address(tokenEx), PriceSource(address(tokenExChainLinkOracle), true, 5 * (10 ** 17), 18, 18, 3600)
        );

        // deposit tokenEx
        tokenEx.mint(poolCreator, 1000 * 1e18);
        vm.prank(poolCreator);
        tokenEx.approve(address(dodoApprove), type(uint256).max);
        vm.prank(poolCreator);
        d3Proxy.makerDeposit(address(d3MM), address(tokenEx), 100 * 1e18);

        // mint user1
        tokenEx.mint(user1, 1000 * 1e18);
        vm.prank(user1);
        tokenEx.approve(address(dodoApprove), type(uint256).max);

        
        
        // set tokenex info
        MakerTypes.TokenMMInfoWithoutCum memory tokenInfo;
        tokenInfo.priceInfo = stickPrice(24, 18, 6, 12, 10);
        tokenInfo.amountInfo = stickAmount(3000, 18, 3000, 18);
        tokenInfo.kAsk = tokenInfo.kBid = 1000;
        tokenInfo.decimal = 18;
        vm.prank(maker);
        d3MakerWithPool.setNewToken(address(tokenEx), true, tokenInfo.priceInfo, tokenInfo.amountInfo, tokenInfo.kAsk, tokenInfo.kBid, 18);

        // now pool has 4+10 token2, 100 tokenEx
        // cr = 4 / 0 = max, safe
        // if user buy 3.9 ether token2, pool safe
        // if user buy 4.1 ether token2, pool unsafe, revert

        // pool safe swap
        uint256 beforeBalance2 = token2.balanceOf(user1);
        uint256 beforeBalanceEx = tokenEx.balanceOf(user1);

        SwapCallbackData memory swapData;
        swapData.data = "";
        swapData.payer = user1;

        d3Proxy.buyTokens(
            address(d3MM),
            user1,
            address(tokenEx),
            address(token2),
            1 ether,
            3 ether,
            abi.encode(swapData),
            block.timestamp + 1000
        );

        d3Proxy.sellTokens(
            address(d3MM),
            user1,
            address(tokenEx),
            address(token2),
            0.5 ether,
            0,
            abi.encode(swapData),
            block.timestamp + 1000
        );
        uint256 afterBalance2 = token2.balanceOf(user1);
        uint256 afterBalanceEx = tokenEx.balanceOf(user1);
        
        assertEq(afterBalance2 - beforeBalance2, 1996802085427539929); // 1.99 near 2
        assertEq(beforeBalanceEx - afterBalanceEx, 1001602215640904029); // 1.00 near 1
        //console.log(afterBalance2 - beforeBalance2);
        //console.log(beforeBalanceEx - afterBalanceEx);

        uint256 token2Res = d3MM.getTokenReserve(address(token2));
        //console.log("token2Res:", token2Res);
        assertEq(token2Res, 11002398554762593269); // 11.0 > borrow 10
        uint256 colR = d3Vault.getCollateralRatio(address(d3MM));
        //console.log(colR);
        assertEq(colR, type(uint256).max);

        // pool unsafe swap
        vm.expectRevert(bytes("D3MM_BELOW_IM_RATIO"));
        d3Proxy.sellTokens(
            address(d3MM),
            user1,
            address(tokenEx),
            address(token2),
            10 ether,
            0,
            abi.encode(swapData),
            block.timestamp + 1000
        );

        vm.expectRevert(bytes("D3MM_BELOW_IM_RATIO"));
        d3Proxy.buyTokens(
            address(d3MM),
            user1,
            address(tokenEx),
            address(token2),
            5 ether,
            10 ether,
            abi.encode(swapData),
            block.timestamp + 1000
        );
    }
}
