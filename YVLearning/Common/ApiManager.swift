//
//  ApiManager.swift
//  YVLearning
//
//  Created by Yash Vyas on 13/08/22.
//

import Foundation

struct ApiManager {
    static let shared = ApiManager()
    private init() {}

    func request<D: Decodable, E: Encodable>(urlString: String,
                                             httpMethod: HTTPMethod = .get,
                                             type: D.Type, data: E? = nil) async throws -> D {
        guard let url = URL(string: urlString) else {
            throw ApiError.invalidUrl
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        if let httpData = data {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            if let httpBody = try? encoder.encode(httpData) {
                urlRequest.httpBody = httpBody
            }
        }
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                // ~= check for a code contains in the range
                throw ApiError.invalidResponse
            }
            guard 200...300 ~= statusCode else {
                throw ApiError.invalidStatusCode(statusCode)
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                return try decoder.decode(D.self, from: data)
            } catch let error {
                throw ApiError.failedToDecode(error)
            }
        } catch let error {
            throw ApiError.failedToLoadData(error)
        }
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    enum ApiError: Error {
        case invalidUrl
        case invalidResponse
        case invalidStatusCode(Int)
        case failedToLoadData(Error)
        case failedToDecode(Error)
    }
}
