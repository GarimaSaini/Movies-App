//
//  MoviesViewModel.swift
//  MoviesUS
//
//  Created by Abhilash Ghogale on 24/03/25.
//

import Foundation

class MoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var query: String = ""
    
    private var currentPage = 1
    private var isLastPage = false
    
    private let movieService: MovieServiceProtocol
    
    init(useCase: MovieServiceProtocol = MovieService()) {
        self.movieService = useCase
    }

    @MainActor
    func searchMovies() {
        guard !isLoading && !isLastPage else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let results = try await movieService.searchMovies(query: query, page: currentPage)
                    if results.isEmpty {
                        self.isLastPage = true
                    } else {
                        self.movies.append(contentsOf: results)
                        self.currentPage += 1
                    }
                    self.isLoading = false
            } catch {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
            }
        }
    }
    
    func cancelSearch() {
        query = ""
        movies = []
    }
}
