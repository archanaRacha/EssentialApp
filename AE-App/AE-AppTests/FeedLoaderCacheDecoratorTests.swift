//
//  FeedLoaderCacheDecoratorTests.swift
//  AE-AppTests
//
//  Created by archana racha on 21/10/24.
//

import XCTest
import AE_Feed

final class FeedLoaderCacheDecorator:FeedLoader {
    private let decoratee: FeedLoader
    init(decoratee:FeedLoader){
        self.decoratee = decoratee
    }
    func load(completion:@escaping(FeedLoader.Result) -> Void){
        decoratee.load(completion: completion)
    }
}
final class FeedLoaderCacheDecoratorTests: XCTestCase,FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess(){
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee:loader)
        expect(sut, toCompleteWith: .success(feed))
    }
    func test_load_deliversErrorOnLoaderFailure() {
        let loader = FeedLoaderStub(result: .failure(anyNSError()))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

    // MARK: - Helpers
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
    }
            
}
