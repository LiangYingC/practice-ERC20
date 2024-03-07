// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol"; // 引入 Foundry 的測試庫，
import "../src/TestERC20.sol"; // 引入 TestERC20 Contract

contract ContractTest is Test { // 定義用於測試的合約，繼承 Foundry 的 Test Contract。test 開頭是測試成功情境，testFail 開頭是測試失敗情境
    event Transfer(address indexed from, address indexed to, uint256 value); // 定義 Transfer Event 用於測試「發送」
    event Approval(address indexed owner, address indexed spender, uint256 value); // 定義 Approval Event 用於測試「批准」

    TestERC20 token; // 宣告 TestERC20 類型的 variable，用於存儲 ERC20 token instance

    address alice = vm.addr(0x1); // 使用 Foundry vm 功能，生成測試 address 給 Alice
    address bob = vm.addr(0x2); // 使用 Foundry vm 功能，生成測試 address 給 Bob

    // 每個測試之前都會運行的 `setUp` 函式 
    function setUp() public { 
        // 實例 TestERC20 token，給予 name 為 "AppWorks School", symbol 為 "AWS"
        token = new TestERC20("AppWorks School", "AWS"); 
    }

    // 測試 token instance name 正確情境
    function testName() external {
        // 斷言 token name 為 "AppWorks School"
        assertEq("AppWorks School", token.name());
    }

    // 測試 token symbol 正確情境
    function testSymbol() external {
        // 斷言 token symbol 為 "AWS"
        assertEq("AWS", token.symbol());
    }

    // 測試 token 發行的正確情境
    function testMint() public {
        // 給 Alice 發行 2 個 token（以 wei 為單位，所以 2e18 表示 2 token）
        token.mint(alice, 2e18); 
        // 斷言發行後的總供應量，需要等於 Alice 所持有的數量
        assertEq(token.totalSupply(), token.balanceOf(alice));
    }

    // 測試 burn token 的正確情境
    function testBurn() public {
        // 給 Alice 發行 10 個 token
        token.mint(alice, 10e18);
        // 斷言 Alice 有 10 個 token
        assertEq(token.balanceOf(alice), 10e18);

        // 從 Alice 的地址帳戶中燒毀 8 個 token
        token.burn(alice, 8e18);

        // 斷言目前總供應剩下 2 個 token，並且 Alice 的餘額剩下 2 個 token
        assertEq(token.totalSupply(), 2e18);
        assertEq(token.balanceOf(alice), 2e18);
    }

    // 測試批准功能的正確情境
    function testApprove() public {
        // 合約批准 Alice 從當前合約地址轉移最多 1 token
        // assertTrue 確保 approve 函數呼叫成功返回 true，表示授權操作成功
        assertTrue(token.approve(alice, 1e18));
        // 合約驗證 Alice 被授權能從當前合約地址（address(this)）轉移的 token 是否確實為 1e18
        // 斷言確認 Alice 獲得的授權額度正好是 1e18 單位
        assertEq(token.allowance(address(this), alice), 1e18);
    }

    // 測試 token transfer 的正確情境
    function testTransfer() external {
        // 呼叫 testMint() 函數，為 Alice 發放 2 token
        testMint();
        // 使用 vm.prank(alice) 模擬 Alice 發起接下來的交易
        vm.prank(alice);
        // Alice 轉移 0.5 token 給 Bob，這裡的轉移是基於之前模擬的 Alice 的身份
        token.transfer(bob, 0.5e18);
        // 斷言目前 Bob 餘額有 0.5
        // 斷言目前 Alice 有 1.5
        assertEq(token.balanceOf(bob), 0.5e18);
        assertEq(token.balanceOf(alice), 1.5e18);
    }

    // 測試 token transfer 的正確情境
    function testTransferFrom() external {
        // 呼叫 testMint() 函數，為 Alice 發放 2 token
        testMint();
        // 使用 vm.prank(alice) 模擬 Alice 發起接下來的交易
        vm.prank(alice);
        // Alice 授權合約地址能從她的賬戶轉出最多 1 token
        token.approve(address(this), 1e18);
        // 從 Alice 的賬戶向 Bob 的賬戶轉賬 0.7 token，並確認操作成功
        assertTrue(token.transferFrom(alice, bob, 0.7e18));
        // 斷言目前 Alice 授權合約的金額，剩下 0.3 token
        assertEq(token.allowance(alice, address(this)), 1e18 - 0.7e18);
        // 斷言目前 Alice 和 Bob 的餘額為 1.3 與 0.7
        assertEq(token.balanceOf(alice), 2e18 - 0.7e18);
        assertEq(token.balanceOf(bob), 0.7e18);
    }

    // 測試鑄造發送的失敗情境，不該直接發行給 address(0)
    function testFailMintToZero() external {
        token.mint(address(0), 1e18);
    }

    // 測試從 address(0) 銷毀 token 的失敗情境，不該被銷毀
    function testFailBurnFromZero() external {
        token.burn(address(0), 1e18);
    }

    // 測試當賬戶餘額不足時，嘗試銷毀代幣需要是失敗的結果
    function testFailBurnInsufficientBalance() external {
        // 呼叫 testMint() 函數，為 Alice 發放 2 token
        testMint();
        // 使用 vm.prank(alice) 模擬 Alice 發起接下來的交易
        vm.prank(alice);
        // 想要銷毀 Alice 3 token，但 Alice token 不足，會失敗
        token.burn(alice, 3e18);
    }

    // 測試向 address(0) 授權 token 的失敗情境
    function testFailApproveToZeroAddress() external {
        token.approve(address(0), 1e18);
    }

    // 測試從模擬 address(0) 進行 token 授權要失敗
    function testFailApproveFromZeroAddress() external {
        // 使用 vm.prank(alice) 模擬 address(0) 發起接下來的授權
        vm.prank(address(0));
        // address(0) 不該具有這個操作，因此失敗
        token.approve(alice, 1e18);
    }

    // 測試向 address(0) 直接轉賬 token 應該失敗
    function testFailTransferToZeroAddress() external {
        // 呼叫 testMint() 函數，為 Alice 發放 2 token
        testMint();
        // 使用 vm.prank(alice) 模擬 Alice 發起接下來的事件
        vm.prank(alice);
        // 直接轉帳給 address(0) 應要失敗
        token.transfer(address(0), 1e18);
    }

    // 測試從 address(0) 轉賬 token 應該失敗
    function testFailTransferFromZeroAddress() external {
        testMint();
        vm.prank(address(0));
        token.transfer(alice, 1e18);
    }

    // 測試當賬戶餘額不足時，轉賬應該失敗
    function testFailTransferInsufficientBalance() external {
        // 呼叫 testMint() 函數，為 Alice 發放 2 token
        testMint();
        // 使用 vm.prank(alice) 模擬 Alice 發起接下來的事件
        vm.prank(alice);
        // 嘗試將 3 token 轉給 bob 但失敗，因為 Alice 只有 2 token
        token.transfer(bob, 3e18);
    }

    // 測試當授權額度不足時，合約從一個賬戶向另一個賬戶轉賬應該失敗
    function testFailTransferFromInsufficientApprove() external {
        // 呼叫 testMint() 函數，為 Alice 發放 2 token
        testMint();
        // 使用 vm.prank(alice) 模擬 Alice 發起接下來的事件
        vm.prank(alice);
        // Alice 授權合約 1 token 的使用權限
        token.approve(address(this), 1e18);
        // 嘗試將 2 token 從 Alice 轉給 Bob 但應要失敗，因為只被授權 1 token
        token.transferFrom(alice, bob, 2e18);
    }

    // 測試當賬戶餘額不足時，合約試圖從一個賬戶向另一個賬戶轉賬應該失敗
    function testFailTransferFromInsufficientBalance() external {
        // 呼叫 testMint() 函數，為 Alice 發放 2 token
        testMint();
        // 使用 vm.prank(alice) 模擬 Alice 發起接下來的事件
        vm.prank(alice);
        // Alice 授權合約無限大的使用權限
        token.approve(address(this), type(uint256).max);
        // 嘗試將 3 token 從 Alice 轉給 Bob 但應要失敗，因為 Alice 總共只有 2 token
        token.transferFrom(alice, bob, 3e18);
    }


// Events 尚未處理，全部註解

    // 測試 mint 時，是否正確觸發 Transfer event
    // 驗證 event 的觸發與記錄是否與預期相符，同時也間接驗證 mint 的正確性。
    // function testMintEvent() public {
        // 設定期望捕獲一個事件，四個 true 參數表示預期會檢查事件的四個方面：事件簽名、參與者地址、數據和主題
        // vm.expectEmit(true, true, true, true);
        // 模擬發送 Transfer Event，表示從 address(0) 向 Alice 地址發行 2 token
        // emit Transfer(address(0), alice, 2e18);

        // 實際在合約中調用 mint 函數並生成 Transfer 事件，向 Alice 發行 2 token
        // token.mint(alice, 2e18);
        // 斷言合約的總供應量等於 Alice 的餘額，確認 mint 操作成功
        // assertEq(token.totalSupply(), token.balanceOf(alice));
    // }

    // 測試當 token burn 時，是否正確觸發 Transfer event
    // 確保 token burn 功能不僅能正常工作，而且還能按照預期處理 event
    // function testBurnEvent() public {
        // 呼叫 testMint() 函數，為 Alice 發放 10 token
        // token.mint(alice, 10e18);
        // 斷言 Alice 餘額為 10 token
        // assertEq(token.balanceOf(alice),10e18);

        // 期待觸發事件，且驗證這個事件的簽名、來源、數據和主題符合我們的預期
        // vm.expectEmit(true, true, true, true);
        // 模擬發出 Transfer event，表示從 alice 轉移 8 token 到 address(0) aka 銷毀之
        // emit Transfer(alice, address(0), 8e18);
        // 實際在合約中調用 burn 時，從 Alice 銷毀 8 token
        // token.burn(alice, 8e18);

        // 總供應量與 Alice 的餘額都是 2 token
        // assertEq(token.totalSupply(), 2e18);
        // assertEq(token.balanceOf(alice),2e18);
    // }

    // 測試轉帳有沒有正時處發 Transfer event
    // function testTransferEvent() external {
        // 呼叫 testMint() 函數，為 Alice 發放 10 token
        // testMint();
        // 模擬 Alice 地址身份，設定後續的操作以 Alice 的身份執行
        // vm.prank(alice);
        // 設置期望捕獲 Transfer event
        // vm.expectEmit(true, true, true, true);
        // 模擬發出 Transfer event，表示從 Alice 向 Bob 轉賬 0.5 token
        // emit Transfer(alice, bob, 0.5e18);
        // 實際在合約中，以 Alice的身份調用 transfer function，向 Bob 轉賬 0.5 token
        // token.transfer(bob, 0.5e18);
        // 斷言確認雙方餘額正確
        // assertEq(token.balanceOf(bob), 0.5e18);
        // assertEq(token.balanceOf(alice), 1.5e18);
    // }
}

