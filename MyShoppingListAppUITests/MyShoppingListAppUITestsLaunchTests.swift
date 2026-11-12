
import XCTest

final class MyShoppingListAppUITestsLaunchTests: XCTestCase {
    
    // 設定ごとの繰り返しは不要なので、1回だけ実行する
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        // 空のメモリDBで起動する（本物のデータを使わない）
        app.launchArguments = ["-UITesting", "-continuousAddEnabled", "NO"]
        app.launch()
        
        // 起動して、最初の画面（カテゴリー）が出ることを確認する
        XCTAssertTrue(app.navigationBars["カテゴリー"].waitForExistence(timeout: 10))
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
