//
//  MovieSearchView.swift
//  MoviesUS
//
//  Created by Abhilash Ghogale on 24/03/25.
//

import SwiftUI

struct MovieSearchView: View {
    @StateObject private var viewModel = MoviesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.movies.isEmpty {
                    Text("Start searching for movies!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.movies) { movie in
                        NavigationLink {
                            MovieDetailView(movie: movie)
                        } label: {
                            MovieView(movie: movie)
                        }
                        .onAppear {
                            if movie == viewModel.movies.last {
                                viewModel.searchMovies()
                            }
                        }
                    }
                    
                }
            }            .searchable(text: $viewModel.query, prompt: "Search Movies")
                .onChange(of: viewModel.query) { newValue in
                    if newValue.isEmpty {
                        viewModel.cancelSearch()
                    }
                }
                .onSubmit(of: .search, viewModel.searchMovies)
                .navigationTitle("Movie Search")
            
            if viewModel.movies.isEmpty {
                Text("No movies found.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

//class MockMovieService: MovieServiceProtocol {
//    func searchMovies(query: String, page: Int) async throws -> [Movie] {
//        <#code#>
//    }
//    
//    func fetchMovies(query: String) async throws -> [Movie] {
//        return [
//            Movie(id: 1, title: "Inception", overview: "A mind-bending thriller.", posterPath: nil, release_date: ""),
//            Movie(id: 2, title: "Interstellar", overview: "A journey beyond the stars.", posterPath: nil, release_date: "")
//        ]
//    }
//}

#Preview {
    MovieSearchView()
}

struct MovieView: View {
    
    var movie: Movie
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: movie.getThumbnailUrl())) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 150)
            .background(Color.gray)
            
            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                Text(movie.release_date ?? "")
            }
            .padding(5)
        }
    }
}
