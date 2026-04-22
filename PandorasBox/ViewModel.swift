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
    
    private let dataFetcher = DataFetcher()
    var trendingMovies: [Title] = []
    var trendingTV: [Title] = []
    var topRatedMovies: [Title] = []
    var topRatedTV: [Title] = []
    var upcomingMovies: [Title] = []
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
            
    func getTitles() async {
        homeStatus = .fetching
        if trendingMovies.isEmpty {
            
            do{
                async let tMovies = dataFetcher.fetchTitles(for: "movie", by: "trending")
                async let tTV = dataFetcher.fetchTitles(for: "tv", by: "trending")
                async let tRMovies = dataFetcher.fetchTitles(for: "movie", by: "top_rated")
                async let tRTV = dataFetcher.fetchTitles(for: "tv", by: "top_rated")
                
                trendingTV = try await tTV
                trendingMovies = try await tMovies
                topRatedTV = try await tRTV
                topRatedMovies = try await tRMovies
                
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
