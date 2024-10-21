//
//  FeedImageDataLoaderSpy.swift
//  AE-AppTests
//
//  Created by archana racha on 21/10/24.
//

import Foundation
import AE_Feed      
public class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

    private(set) var cancelledURLs = [URL]()

    var loadedURLs: [URL] {
        return messages.map { $0.url }
    }

    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        func cancel() { callback() }
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
