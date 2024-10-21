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
    private let cache: FeedCache
    init(decoratee:FeedLoader,cache:FeedCache){
        self.decoratee = decoratee
        self.cache = cache
    }
    func load(completion:@escaping(FeedLoader.Result) -> Void){
        decoratee.load { [weak self] result in
            completion(result.map { feed in
            
                self?.cache.saveIgnoringResult(feed)
            
                return feed
            })
        }
    }
}
private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
final class FeedLoaderCacheDecoratorTests: XCTestCase,FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess(){
        let feed = uniqueFeed()

        let sut = makeSUT(loaderResult: .success(feed))
        expect(sut, toCompleteWith: .success(feed))
    }
    func test_load_deliversErrorOnLoaderFailure() {
 
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    func test_load_cachesLoadedFeedOnLoaderSuccess(){
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache:cache)
        sut.load { _ in}
    }
    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)

        sut.load { _ in }

        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache feed on load error")
    }
    // MARK: - Helpers

    private func makeSUT(loaderResult: FeedLoader.Result,cache: CacheSpy = .init(),  file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
    }
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()

        enum Message: Equatable {
            case save([FeedImage])
        }

        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
            
}
