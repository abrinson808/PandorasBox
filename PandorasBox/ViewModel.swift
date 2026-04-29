//
//  ViewModel.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/1/26.
//

import Foundation

@Observable
class ViewModel {
    enum FetchStatus{
        case notStarted
        case fetching
        case success
        case failed(underlyingError: Error)
    }
    private(set) var homeStatus: FetchStatus = .notStarted
    private(set) var videoIdStatus: FetchStatus = .notStarted
    private(set) var upcomingStatus: FetchStatus = .notStarted
    private(set) var detailStatus: FetchStatus = .notStarted
    private(set) var personDetailStatus: FetchStatus = .notStarted
    private(set) var suggestionsStatus: FetchStatus = .notStarted
    
    private let dataFetcher = DataFetcher()
    var trendingMovies: [Title] = []
    var trendingTV: [Title] = []
    var topRatedMovies: [Title] = []
    var topRatedTV: [Title] = []
    var upcomingMovies: [Title] = []
    var nowPlaying: [Title] = []
    var heroTitle = Title.previewTitles[0]
    var videoId = ""
    
    var genres: [Genre] = []
    var voteAverage: Double = 0.0
    var cast: [CastMember] = []
    var watchProviders: WatchProviderCountry?
    var similarTitles: [SimilarTitle] = []
    var personDetail: PersonDetailResponse?
    var mostRecentCredit: PersonCredit?
    var personVideoId: String = ""
    var suggestions: [SimilarTitle] = []
            
    func getTitles() async {
        homeStatus = .fetching
        if trendingMovies.isEmpty {
            
            do{
                async let tMovies = dataFetcher.fetchTitles(for: "movie", by: "trending")
                async let tTV = dataFetcher.fetchTitles(for: "tv", by: "trending")
                async let tRMovies = dataFetcher.fetchTitles(for: "movie", by: "top_rated")
                async let tRTV = dataFetcher.fetchTitles(for: "tv", by: "top_rated")
                async let nPlaying = dataFetcher.fetchTitles(for: "movie", by: "now_playing")
                
                trendingTV = try await tTV
                trendingMovies = try await tMovies
                topRatedTV = try await tRTV
                topRatedMovies = try await tRMovies
                nowPlaying = try await nPlaying
                
                if let title = trendingTV.randomElement() {
                    heroTitle = title
                }
                homeStatus = .success
            } catch {
                print(error)
                homeStatus = .failed(underlyingError: error)
            }
        } else{
            homeStatus = .success
        }
    }
    
    func getVideoId(for titleId: Int, mediaType: String) async {
        videoIdStatus = .fetching

        do{
            videoId = try await dataFetcher.fetchTrailerID(for: titleId, mediaType: mediaType)
            videoIdStatus = .success
        } catch {
            print(error)
            videoIdStatus = .failed(underlyingError: error)
        }
    }
    
    func getTitleDetail(for titleId: Int, mediaType: String) async {
        detailStatus = .fetching

        do {
            let detail = try await dataFetcher.fetchTitleDetail(for: titleId, mediaType: mediaType)

            genres = detail.genres
            voteAverage = detail.voteAverage
            cast = Array(detail.credits.cast.prefix(10))
            watchProviders = detail.watchProviders.results["US"]
            similarTitles = detail.similar.results

            detailStatus = .success
        } catch {
            print(error)
            detailStatus = .failed(underlyingError: error)
        }
    }
    
    func getSuggestions(from savedTitles: [Title]) async {
        suggestionsStatus = .fetching
        
        guard !savedTitles.isEmpty else {
            suggestionsStatus = .success
            return
        }
        
        do {
            // Pick up to 3 random titles from the watchlist to base suggestions on
            let sampleTitles = Array(savedTitles.shuffled().prefix(3))
            var allSuggestions: [SimilarTitle] = []
            
            for title in sampleTitles {
                guard let titleId = title.id else { continue }
                let mediaType = title.mediaType ?? "movie"
                let similar = try await dataFetcher.fetchSimilarTitles(for: titleId, mediaType: mediaType)
                allSuggestions.append(contentsOf: similar)
            }
            
            // Remove duplicates and titles already in the watchlist
            let savedIds = Set(savedTitles.compactMap { $0.id })
            var seenIds = Set<Int>()
            suggestions = allSuggestions.filter { title in
                let isNew = !savedIds.contains(title.id) && !seenIds.contains(title.id)
                seenIds.insert(title.id)
                return isNew
            }
            .shuffled()
            
            suggestionsStatus = .success
        } catch {
            print(error)
            suggestionsStatus = .failed(underlyingError: error)
        }
    }
    
    func getPersonDetail(for personId: Int) async {
        personDetailStatus = .fetching
        
        do {
            let detail = try await dataFetcher.fetchPersonDetail(for: personId)
            personDetail = detail
            let allCredits = (detail.combinedCredits.cast ?? []) + (detail.combinedCredits.crew ?? [])
            mostRecentCredit = allCredits
                .sorted {$0.sortDate > $1.sortDate}
                .first
            
            if let credit = mostRecentCredit {
                personVideoId = try await dataFetcher.fetchTrailerID(
                    for: credit.id,
                    mediaType: credit.mediaType ?? "movie")
            }
            personDetailStatus = .success
        } catch {
            print(error)
            personDetailStatus = .failed(underlyingError: error)
        }
    }
    
    func getUpcomingMovies() async {
        upcomingStatus = .fetching
        
        do{
            upcomingMovies = try await dataFetcher.fetchTitles(for: "movie", by: "upcoming")
            upcomingStatus = .success
        } catch {
            print(error)
            upcomingStatus = .failed(underlyingError: error)
        }
    }
}
