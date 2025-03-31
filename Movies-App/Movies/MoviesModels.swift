//
//  MoviesModels.swift
//  MoviesUS
//
//  Created by Abhilash Ghogale on 24/03/25.
//

import Foundation

struct Movie: Codable,Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let release_date: String?

    func getThumbnailUrl() -> String {
        return "https://image.tmdb.org/t/p/w500" + (posterPath ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, release_date
        case posterPath = "poster_path"
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
}
