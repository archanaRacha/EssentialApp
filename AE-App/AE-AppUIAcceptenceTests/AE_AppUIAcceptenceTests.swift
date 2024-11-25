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
        app.launchArguments = ["-reset","-connectivity","online"]
        app.launch()
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertEqual(firstImage.exists, true)
    }
    func test_onLaunch_displayCacheRemoteFeedWhenCustomerHasNoConnectivity(){
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset","-connectivity","online"]
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity","offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count,2)
        let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstCachedImage.exists)
    }
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache(){
        let app = XCUIApplication()
        app.launchArguments = ["-reset","-connectivity","offline"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count,0)
    }
}
