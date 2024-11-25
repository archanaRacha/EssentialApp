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
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertEqual(firstImage.exists, true)
    }
}
