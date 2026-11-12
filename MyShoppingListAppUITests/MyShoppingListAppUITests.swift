
//  前提:
//  - アプリ側で "-UITesting" 起動引数のときメモリ上のDBを使う（MyShoppingListAppApp.swift）
//  - 次の accessibilityIdentifier を付けてある
//      addFolderButton / folderNameField / folderSaveButton / folderCloseButton
//      addMenuButton / itemNameField / itemSaveButton / itemCloseButton
//  - 日本語入力の不安定さを避けるため、入力する名前は英数字にしている
//

import XCTest

final class MyShoppingListAppUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // UIテストは、失敗したらすぐ止める
        continueAfterFailure = false
    }
    
    // MARK: - ヘルパー
    
    /// 空のメモリDBで起動する。「続けて登録」の保存値も毎回こちらで決める
    @MainActor
    private func launchApp(continuousAdd: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-UITesting",
            "-continuousAddEnabled", continuousAdd ? "YES" : "NO"
        ]
        app.launch()
        return app
    }
    
    /// カテゴリー画面でフォルダを追加し、一覧に出るまで待つ
    @MainActor
    private func addFolder(_ name: String, in app: XCUIApplication) {
        app.buttons["addFolderButton"].tap()
        let field = app.textFields["folderNameField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "フォルダ名の入力欄が出ません")
        field.tap()
        field.typeText(name)
        app.buttons["folderSaveButton"].tap()
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 5), "\(name) が一覧に出ません")
    }
    
    /// フォルダの中でアイテム追加画面を開く
    @MainActor
    private func openItemSheet(in app: XCUIApplication) {
        app.buttons["addMenuButton"].tap()
        app.buttons["購入アイテムを追加"].tap()
        XCTAssertTrue(app.textFields["itemNameField"].waitForExistence(timeout: 5),
                      "アイテム名の入力欄が出ません")
    }
    
    /// アイテム追加画面で名前を入力して保存する
    @MainActor
    private func submitItem(_ name: String, in app: XCUIApplication) {
        let field = app.textFields["itemNameField"]
        field.tap()
        field.typeText(name)
        app.buttons["itemSaveButton"].tap()
    }
    
    // MARK: - 起動
    
    @MainActor
    func test_起動直後は空表示が出る() throws {
        let app = launchApp()
        
        XCTAssertTrue(app.navigationBars["カテゴリー"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["フォルダがありません"].exists)
    }
    
    // MARK: - フォルダ（正常系）
    
    @MainActor
    func test_フォルダを追加すると一覧に並ぶ() throws {
        let app = launchApp()
        
        addFolder("Food", in: app)
        
        XCTAssertFalse(app.staticTexts["フォルダがありません"].exists, "空表示が消えていません")
    }
    
    @MainActor
    func test_フォルダを削除できる() throws {
        let app = launchApp()
        addFolder("Food", in: app)
        
        app.cells.containing(.staticText, identifier: "Food").firstMatch.swipeLeft()
        app.buttons["削除"].tap()
        
        let alert = app.alerts["フォルダを削除しますか？"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "確認アラートが出ません")
        alert.buttons["削除"].tap()
        
        XCTAssertTrue(app.staticTexts["Food"].waitForNonExistence(timeout: 5), "フォルダが消えていません")
    }
    
    // MARK: - フォルダ（異常系）
    
    @MainActor
    func test_同じ名前のフォルダは保存できない() throws {
        let app = launchApp()
        addFolder("Food", in: app)
        
        app.buttons["addFolderButton"].tap()
        let field = app.textFields["folderNameField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("Food")
        
        XCTAssertTrue(app.staticTexts["既にあります"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["folderSaveButton"].isEnabled, "同名なのに保存できてしまいます")
    }
    
    @MainActor
    func test_名前が空のままでは保存できない() throws {
        let app = launchApp()
        
        app.buttons["addFolderButton"].tap()
        XCTAssertTrue(app.textFields["folderNameField"].waitForExistence(timeout: 5))
        
        XCTAssertFalse(app.buttons["folderSaveButton"].isEnabled)
    }
    
    @MainActor
    func test_フォルダ追加を閉じても何も追加されない() throws {
        let app = launchApp()
        
        app.buttons["addFolderButton"].tap()
        XCTAssertTrue(app.textFields["folderNameField"].waitForExistence(timeout: 5))
        app.buttons["folderCloseButton"].tap()
        
        XCTAssertTrue(app.staticTexts["フォルダがありません"].waitForExistence(timeout: 5))
    }
    
    // MARK: - アイテム
    
    @MainActor
    func test_フォルダの中でアイテムを追加できる() throws {
        let app = launchApp()
        addFolder("Food", in: app)
        app.staticTexts["Food"].tap()
        
        openItemSheet(in: app)
        submitItem("Milk", in: app)
        
        // 単発モードなので、閉じて一覧に出る
        XCTAssertTrue(app.staticTexts["Milk"].waitForExistence(timeout: 5), "アイテムが一覧に出ません")
        XCTAssertFalse(app.textFields["itemNameField"].exists, "画面が閉じていません")
    }
    
    @MainActor
    func test_アイテム名が空のままでは追加できない() throws {
        let app = launchApp()
        addFolder("Food", in: app)
        app.staticTexts["Food"].tap()
        
        openItemSheet(in: app)
        
        XCTAssertFalse(app.buttons["itemSaveButton"].isEnabled)
    }
    
    @MainActor
    func test_続けて登録がオンなら画面を閉じずに連続で追加できる() throws {
        let app = launchApp(continuousAdd: true)
        addFolder("Food", in: app)
        app.staticTexts["Food"].tap()
        
        openItemSheet(in: app)
        submitItem("Milk", in: app)
        
        // 画面は開いたまま。名前は空に戻るので、保存ボタンは押せない
        XCTAssertTrue(app.textFields["itemNameField"].exists)
        XCTAssertFalse(app.buttons["itemSaveButton"].isEnabled)
        
        // 続けて2つ目を追加できる
        submitItem("Eggs", in: app)
        app.buttons["itemCloseButton"].tap()
        
        XCTAssertTrue(app.staticTexts["Milk"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Eggs"].waitForExistence(timeout: 5))
    }
}
