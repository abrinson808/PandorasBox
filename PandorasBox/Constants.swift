//
//  Constants.swift
//  PandorasBox
//
//  Created by Alex Brinson on 3/31/26.
//

import Foundation
import SwiftUI

struct Constants {
    static let homeString = "Home"
    static let upcomingString = "Upcoming"
    static let searchString = "Search"
    static let downloadString = "Download"
    static let playString = "Play"
    static let trendingMoviesString = "Trending Movies"
    static let trendingTVString = "Trending TV"
    static let topRatedMovieString = "Top Rated Movies"
    static let topRatedTVString = "Top Rated TV"
    static let movieSearchString = "Movie Search"
    static let tvSearchString = "TV Search"
    static let moviePlaceholderString = "Search for a Movie"
    static let tvPlaceholderString = "Search for a Tv Show"

    
    static let homeIconString = "house"
    static let upcomingIconString = "play.circle"
    static let searchIconString = "magnifyingglass"
    static let downloadIconString = "arrow.down.to.line"
    static let tvIconString = "tv"
    static let movieIconString = "movieclapper"
    
    static let testTitleURL = "https://image.tmdb.org/t/p/original/cCx1m530ph5FmtabVVUpUchEmhe.jpg"
    static let testTitleURL2 = "https://image.tmdb.org/t/p/original/j1yZpgJzjDCbXyA7voSC7SEhcZY.jpg"
    static let testTitleURL3 = "https://image.tmdb.org/t/p/original/56ofGPMOZCwlTjTao5fB7vnGOoj.jpg"
    
    static let posterURLStart = "https://image.tmdb.org/t/p/original"
    
    static func addPosterPath(to titles: inout[Title]) {
        for index in titles.indices {
            if let path = titles[index].posterPath {
                titles[index].posterPath = Constants.posterURLStart + path
            }
        }
    }
}

extension Text {
    func ghostButton() -> some View {
        self
            .frame(width: 100, height: 50)
            .foregroundStyle(.buttonText)
            .bold()
            .background {
                RoundedRectangle(cornerRadius:20, style: .continuous)
                    .stroke(.buttonBorder,lineWidth: 5)
            }
    }
}

extension Text {
    func errorMessage() -> some View {
        self
            .foregroundStyle(.red)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 10))
    }
}
