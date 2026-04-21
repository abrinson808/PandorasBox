//
//  TitleDetailResponse.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/20/26.
//

import Foundation

// MARK: - Top-level response
struct TitleDetailResponse: Decodable {
    let genres: [Genre]
    let voteAverage: Double
    let credits: Credits
    let watchProviders: WatchProviderResult
    let similar: SimilarResult

    enum CodingKeys: String, CodingKey {
        case genres
        case voteAverage
        case credits
        case watchProviders = "watch/providers"
        case similar
    }
}

// MARK: - Genre
struct Genre: Decodable, Identifiable {
    let id: Int
    let name: String
}

// MARK: - Credits & Cast
struct Credits: Decodable {
    let cast: [CastMember]
}

struct CastMember: Decodable, Identifiable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int
}

// MARK: - Watch Providers
struct WatchProviderResult: Decodable {
    let results: [String: WatchProviderCountry]
}

struct WatchProviderCountry: Decodable {
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
}

struct WatchProvider: Decodable, Identifiable {
    let providerId: Int
    let providerName: String
    let logoPath: String?

    var id: Int { providerId }
}

// MARK: - Similar Titles
struct SimilarResult: Decodable {
    let results: [SimilarTitle]
}

struct SimilarTitle: Decodable, Identifiable {
    let id: Int
    let title: String?
    let name: String?
    let posterPath: String?
    let overview: String?
    let mediaType: String?

    var displayName: String {
        (name ?? title) ?? ""
    }
}
