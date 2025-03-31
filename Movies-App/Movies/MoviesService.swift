//
//  MoviesService.swift
//  MoviesUS
//
//  Created by Abhilash Ghogale on 24/03/25.
//

import Foundation

protocol MovieServiceProtocol {
    func searchMovies(query: String, page: Int) async throws -> [Movie]
}

class MovieService: MovieServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        let endpoint = MovieSearchEndpoint(query: query, page: page)
        let response: MovieResponse = try await networkService.execute(endpoint: endpoint)
        return response.results
    }
}

// MARK: - Movie Search Endpoint
struct MovieSearchEndpoint: Endpoint {
    let query: String
    let page: Int
    
    var path: String { "/search/movie" }
    var method: HTTPMethod { .GET }
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
    }
}
