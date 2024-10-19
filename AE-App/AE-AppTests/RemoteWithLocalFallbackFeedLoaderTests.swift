//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  AE-AppTests
//
//  Created by archana racha on 19/10/24.
//

import XCTest
import AE_Feed

class FeedLoaderWithFallbackComposite : FeedLoader{
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
        trackMemoryLeaks(primaryLoader, file: file, line: line)
        trackMemoryLeaks(fallbackLoader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
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
    func trackMemoryLeaks(_ instance:AnyObject,file:StaticString = #file,line:UInt = #line){
       addTeardownBlock { [weak instance] in
           XCTAssertNil(instance,"instance should have been deallocated. Potential memory leak.",file: file, line:  line)
       }
   }
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }
    private func anyNSError() -> NSError{
        return NSError(domain: "any error", code: 0)
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
