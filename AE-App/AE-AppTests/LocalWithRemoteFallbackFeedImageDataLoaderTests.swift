//
//  LocalWithRemoteFallbackFeedImageDataLoaderTests.swift
//  AE-AppTests
//
//  Created by archana racha on 19/10/24.
//

import XCTest
import AE_Feed

private class FeedImageDataLoaderWithFallbackComposite : FeedImageDataLoader {
    private let primaryImageDataLoader:FeedImageDataLoader
    private let fallbackImageDataLoader:FeedImageDataLoader
    init(primaryImageDataLoader: FeedImageDataLoader, fallbackImageDataLoader: FeedImageDataLoader) {
        self.primaryImageDataLoader = primaryImageDataLoader
        self.fallbackImageDataLoader = fallbackImageDataLoader
    }
    private class TaskWrapper : FeedImageDataLoaderTask{
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    func loadImageData(from url: URL, completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> any AE_Feed.FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primaryImageDataLoader.loadImageData(from: url) {[weak self] result in
            switch result{
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallbackImageDataLoader.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }
}

final class FeedImageDataLoaderWithFallbackTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primaryImageDataLoader: primaryLoader, fallbackImageDataLoader: fallbackLoader)

        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        
        let url = anyURL()
        
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
            let url = anyURL()
            let (sut, primaryLoader, fallbackLoader) = makeSUT()

            _ = sut.loadImageData(from: url) { _ in }

            primaryLoader.complete(with: anyNSError())

            XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
            XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
        }
    
// MARK: - Helpers
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy){
        
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primaryImageDataLoader: primaryLoader, fallbackImageDataLoader: fallbackLoader)
        trackForMemoryLeaks(primaryLoader,file:file,line:line)
        trackForMemoryLeaks(fallbackLoader,file:file,line:line)
        trackForMemoryLeaks(sut,file:file,line:line)
        return (sut, primaryLoader, fallbackLoader)
        
    }
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
            addTeardownBlock { [weak instance] in
                XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
            }
        }
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }

        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
   
}
