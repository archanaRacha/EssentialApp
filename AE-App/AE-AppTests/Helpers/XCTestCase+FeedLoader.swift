//
//  XCTestCase+FeedLoader.swift
//  AE-AppTests
//
//  Created by archana racha on 21/10/24.
//

//import XCTest
//import AE_Feed
//
//protocol FeedLoaderTestCase : XCTestCase{}
//
//extension FeedLoaderTestCase {
//    public func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
//
//        let exp = expectation(description: "Wait for load completion")
//
//        sut.load { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case let (.success(receivedFeed), .success(expectedFeed)):
//                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
//
//            case (.failure, .failure):
//                break
//
//            default:
//                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
//            }
//
//            exp.fulfill()
//        }
//
//        wait(for: [exp], timeout: 1.0)
//    }
//
//}
