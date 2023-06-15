/*

    Copyright 2023 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0*/

pragma solidity 0.8.16;

import "../../../TestContext.t.sol";

contract D3UserQuotaTest is TestContext {

    using DecimalMath for uint256;

    function setUp() public {
        createTokens();
        createD3Oracle();
        // createMockOracle();
        // createMockD3Vault();
        createD3VaultTwo();
        createD3Proxy();
    }

    function testEnableQuota() public {
        d3UserQuota.enableQuota(address(token1), false);
        uint256 userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, type(uint256).max);
    }

    function testEnableGlobalQuota() public {
        d3UserQuota.enableQuota(address(token1), true);
        d3UserQuota.enableGlobalQuota(address(token1), true);
        d3UserQuota.setGlobalQuota(address(token1), uint256(1300));
        uint256 userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 1 * 10 ** 8);
    }

    function testQuotaTokenHold() public {
        d3UserQuota.enableQuota(address(token1), true);
        d3UserQuota.enableGlobalQuota(address(token1), false);
        d3UserQuota.setQuotaTokenHold(address(dodo));
        uint256[] memory _quotaTokenHoldAmount = new uint256[](3);
        _quotaTokenHoldAmount[0] = 100 * 1e18;
        _quotaTokenHoldAmount[1] = 1000 * 1e18;
        _quotaTokenHoldAmount[2] = 10000 * 1e18;
        uint256[] memory _quotaTokenAmount = new uint256[](3);
        _quotaTokenAmount[0] = 100;
        _quotaTokenAmount[1] = 1000;
        _quotaTokenAmount[2] = 10000;
        d3UserQuota.setQuotaTokennAmount(_quotaTokenHoldAmount, _quotaTokenAmount);
        uint256 userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 100 * 10 ** 8 / uint256(1300));

        faucetToken(address(dodo), user1, 10 * 1e18);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 100 * 10 ** 8 / uint256(1300));

        faucetToken(address(dodo), user1, 200 * 1e18);
        // uint256 dodoBalance = MockERC20(address(dodo)).balanceOf(user1);
        // console2.log("dodo balance ",dodoBalance);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 1000 * 10 ** 8 / uint256(1300));

        faucetToken(address(dodo), user1, 1000 * 1e18);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 10000 * 10 ** 8 / uint256(1300));

        faucetToken(address(dodo), user1, 10000 * 1e18);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 10000 * 10 ** 8 / uint256(1300));  
    }

    function testQuotaTokenHoldTwo() public {
        vm.prank(user1);
        token1.approve(address(dodoApprove), type(uint256).max);
        d3UserQuota.enableQuota(address(token1), true);
        d3UserQuota.enableGlobalQuota(address(token1), false);
        d3UserQuota.setQuotaTokenHold(address(dodo));
        uint256[] memory _quotaTokenHoldAmount = new uint256[](3);
        _quotaTokenHoldAmount[0] = 100 * 1e18;
        _quotaTokenHoldAmount[1] = 1000 * 1e18;
        _quotaTokenHoldAmount[2] = 10000 * 1e18;
        uint256[] memory _quotaTokenAmount = new uint256[](3);
        _quotaTokenAmount[0] = 100;
        _quotaTokenAmount[1] = 1000;
        _quotaTokenAmount[2] = 10000;
        d3UserQuota.setQuotaTokennAmount(_quotaTokenHoldAmount, _quotaTokenAmount);
        faucetToken(address(token1), user1, 1000 * 1e8);
        userDeposit(user1,address(token1), 1 * 1e6);
        uint256 userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 100* 10 ** 8/ uint256(1300) - 1 * 1e6);

        faucetToken(address(dodo), user1, 10 * 1e18);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 100* 10 ** 8/ uint256(1300) - 1 * 1e6);

        faucetToken(address(dodo), user1, 200 * 1e18);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 1000 * 10 ** 8/ uint256(1300) - 1 * 1e6);

        faucetToken(address(dodo), user1, 1000 * 1e18);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 10000 * 10 ** 8/ uint256(1300) - 1 * 1e6);

        faucetToken(address(dodo), user1, 10000 * 1e18);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 10000 * 10 ** 8/ uint256(1300) - 1 * 1e6);

        faucetToken(address(dodo), user1, 20000 * 1e18);
        userQuota = d3UserQuota.getUserQuota(user1, address(token1));
        assertEq(userQuota, 10000 * 10 ** 8/ uint256(1300) - 1 * 1e6);
    }

    function testCheckQuota() public {
        d3UserQuota.enableQuota(address(token1), true);
        d3UserQuota.enableGlobalQuota(address(token1), false);
        d3UserQuota.setQuotaTokenHold(address(dodo));
        uint256[] memory _quotaTokenHoldAmount = new uint256[](3);
        _quotaTokenHoldAmount[0] = 100 * 1e18;
        _quotaTokenHoldAmount[1] = 1000 * 1e18;
        _quotaTokenHoldAmount[2] = 10000 * 1e18;
        uint256[] memory _quotaTokenAmount = new uint256[](3);
        _quotaTokenAmount[0] = 100;
        _quotaTokenAmount[1] = 1000;
        _quotaTokenAmount[2] = 10000;
        d3UserQuota.setQuotaTokennAmount(_quotaTokenHoldAmount, _quotaTokenAmount);
        bool check = d3UserQuota.checkQuota(user1, address(token1), 100 * 10 ** 8 / uint256(1300));
        assertEq(check, true);
        check = d3UserQuota.checkQuota(user1, address(token1), 100 * 10 ** 8 / uint256(1300) + 1);
        assertEq(check, false);

        faucetToken(address(dodo), user1, 10 * 1e18);
        check = d3UserQuota.checkQuota(user1, address(token1), 100 * 10 ** 8 / uint256(1300));
        assertEq(check, true);
        check = d3UserQuota.checkQuota(user1, address(token1), 100 * 10 ** 8 / uint256(1300) + 1);
        assertEq(check, false);

        faucetToken(address(dodo), user1, 200 * 1e18);
        check = d3UserQuota.checkQuota(user1, address(token1), 1000 * 10 ** 8 / uint256(1300));
        assertEq(check, true);
        check = d3UserQuota.checkQuota(user1, address(token1), 1000 * 10 ** 8 / uint256(1300) + 1);
        assertEq(check, false);

        faucetToken(address(dodo), user1, 1000 * 1e18);
        check = d3UserQuota.checkQuota(user1, address(token1), 10000 * 10 ** 8 / uint256(1300));
        assertEq(check, true);
        check = d3UserQuota.checkQuota(user1, address(token1), 10000 * 10 ** 8 / uint256(1300) + 1);
        assertEq(check, false);

        faucetToken(address(dodo), user1, 10000 * 1e18);
        check = d3UserQuota.checkQuota(user1, address(token1), 10000 * 10 ** 8 / uint256(1300));
        assertEq(check, true);
        check = d3UserQuota.checkQuota(user1, address(token1), 10000 * 10 ** 8 / uint256(1300) + 1);
        assertEq(check, false);
    }
}
