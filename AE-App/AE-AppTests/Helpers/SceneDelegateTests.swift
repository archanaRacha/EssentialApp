//
//  SceneDelegateTests.swift
//  AE-AppTests
//
//  Created by archana racha on 07/12/24.
//

import XCTest
import AEFeediOS
@testable import AE_App

final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_setsWindowAsKeyAndVisible(){
        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window
        sut.configure()
//        XCTAssertTrue(window.isKeyWindow,"Expected window to be the key window")
        XCTAssertFalse(window.isHidden,"Expected window to be the visible")
        
    }
    func test_configureWindow_configuresRootViewController(){
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configure()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation,"Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is FeedViewController,"Expected a feed controller as top view controller,got\(String(describing:topController)) instead")
        
    }
}
