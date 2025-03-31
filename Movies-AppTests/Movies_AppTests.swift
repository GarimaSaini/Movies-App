//
//  Movies_AppTests.swift
//  Movies-AppTests
//
//  Created by Fineotech on 2025-03-31.
//

import XCTest
@testable import Movies_App

let mocMovies = [Movie(id: 0, title: "Test1", overview: "Overview1", posterPath: "path1", release_date: ""),
                 Movie(id: 1, title: "Test2", overview: "Info 2", posterPath: "path2", release_date: "")]
@MainActor
@MainActor
final class MoviesUSTests: XCTestCase {
    
    func testSearchMovies_Success() async {
        let mockService = MockMovieService(movies: mocMovies)
        let viewModel = MoviesViewModel(useCase: mockService)
        
        await MainActor.run {
            viewModel.query = "Test"
            viewModel.searchMovies()
        }

        let expectation = XCTestExpectation(description: "Wait for search completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(viewModel.movies.count, 2)
        XCTAssertEqual(viewModel.movies.first?.title, "Test1")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSearchMovies_EmptyQuery() async {
        let mockService = MockMovieService(movies: [])
        let viewModel = MoviesViewModel(useCase: mockService)

        await MainActor.run {
            viewModel.query = ""
            viewModel.searchMovies()
        }
        
        XCTAssertTrue(viewModel.movies.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchMovies_Failure() async {
        let mockService = MockMovieService(error: NSError(domain: "TestError", code: -1, userInfo: nil))
        let viewModel = MoviesViewModel(useCase: mockService)

        await MainActor.run {
            viewModel.query = "Test"
            viewModel.searchMovies()
        }

        let expectation = XCTestExpectation(description: "Wait for error response")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertTrue(viewModel.movies.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testCancelSearch() async {
        let mockService = MockMovieService(movies: [Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "path", release_date: "")])
        let viewModel = MoviesViewModel(useCase: mockService)

        await MainActor.run {
            viewModel.query = "Test"
            viewModel.movies = [Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "path", release_date: "")]
            viewModel.cancelSearch()
        }
        
        XCTAssertEqual(viewModel.query, "")
        XCTAssertTrue(viewModel.movies.isEmpty)
    }
}

// ✅ Fix: Ensure MockMovieService Filters Movies Based on Query
class MockMovieService: MovieServiceProtocol {
    private let movies: [Movie]
    private let error: Error?
    
    init(movies: [Movie] = [], error: Error? = nil) {
        self.movies = movies
        self.error = error
    }
    
    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        if let error = error {
            throw error
        }
        return movies.filter { $0.title.contains(query) }
    }
}
