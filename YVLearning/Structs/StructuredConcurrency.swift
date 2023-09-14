//
//  StructuredConcurrency.swift
//  YVLearning
//
//  Created by Yash Vyas on 10/02/22.
//

import UIKit

struct StructuredConcurrency {

    func fetchImagesWithCompletion(_ completion: (Result<[UIImage], Error>) -> Void) {
        completion(.success([]))
    }

    func fetchImagesWithContinuation() async throws -> [UIImage] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchImagesWithCompletion { result in
                continuation.resume(with: result)
            }
        }
    }

    @available(*, deprecated, renamed: "fetchImages()")
    func fetchImages(completion: @escaping (Result<[UIImage], Error>) -> Void) {
        Task {
            do {
                let result = try await fetchImages()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func fetchImages() async throws -> [UIImage] {
        return []
    }

    func play() {
        Task {
            let imagesSerial = try? await fetchImages()
            debugPrint("fetchImages: \(imagesSerial?.count ?? 0)")

            async let imagesParallel = try? fetchImages()
            debugPrint("fetchImages async let: \(await imagesParallel?.count ?? 0)")
        }
    }

    init() {
        play()
    }
}
