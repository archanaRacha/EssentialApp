//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  AE-AppTests
//
//  Created by archana racha on 19/10/24.
//

import XCTest
import AE_Feed

class FeedLoaderWithFallbackComposite {
    private let primary : FeedLoader
    private let fallback: FeedLoader
    init(primary:FeedLoader,fallback:FeedLoader){
        self.primary = primary
        self.fallback = fallback
    }
    func load(completion:@escaping(FeedLoader.Result) -> Void){
        primary.load {[weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
class FeedLoaderWithFallbackCompositeTests:XCTestCase{
    func test_load_deliversPrimaryFeedOnPrimarySuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        
        let sut = FeedLoaderWithFallbackComposite(primary:primaryLoader,fallback:fallbackLoader)
        let exp = expectation(description: "wait for load completion")
        sut.load{ result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
                break
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1)
        
    }
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
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
