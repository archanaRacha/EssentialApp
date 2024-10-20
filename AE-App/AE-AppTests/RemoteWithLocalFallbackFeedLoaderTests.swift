//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  AE-AppTests
//
//  Created by archana racha on 19/10/24.
//

import XCTest
import AE_Feed
import AE_App

class FeedLoaderWithFallbackCompositeTests:XCTestCase{
    func test_load_deliversPrimaryFeedOnPrimarySuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        
        let sut = makeSUT(primaryResult: .success(primaryFeed) , fallbackResult: .success(fallbackFeed))

        expect(sut, toCompletewith: .success(primaryFeed))
        
    }
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        
        let sut = makeSUT(primaryResult: .failure(anyNSError()) , fallbackResult: .success(fallbackFeed))
        expect(sut, toCompletewith: .success(fallbackFeed))
        
    }
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure(){
        let sut = makeSUT(primaryResult: .failure(anyNSError()) , fallbackResult: .failure(anyNSError()))
        expect(sut, toCompletewith: .failure(anyNSError()))
    }
    //MARK: Helpers
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult:FeedLoader.Result, file: StaticString = #file,line: UInt = #line) -> FeedLoader{
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
        
    }
    
    private func expect(_ sut: FeedLoader, toCompletewith expectedResult: FeedLoader.Result, file: StaticString = #file,line: UInt = #line){
        let exp = expectation(description: "wait for load completion")
        sut.load{ receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
                break
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult) result, got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1)
    }
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url:anyURL())]
    }
    private class LoaderStub : FeedLoader {
        
        private var result : FeedLoader.Result
        
        init(result : FeedLoader.Result){
            self.result = result
        }
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
