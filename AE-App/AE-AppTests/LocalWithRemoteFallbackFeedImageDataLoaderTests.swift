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
    
// MARK: - Helpers

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
    }
   
}
