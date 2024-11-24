//
//  AE_AppUIAcceptenceTests.swift
//  AE-AppUIAcceptenceTests
//
//  Created by archana racha on 08/11/24.
//

import XCTest

final class AE_AppUIAcceptenceTests: XCTestCase {

    func test_onLaunch_displayRemoteFeedWhenCustomerHasConnectivity(){
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.cells.count, 22)
        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
    }
}
