//
//  SearchViewModel.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/7/26.
//

import Foundation

enum SearchMode: String, CaseIterable {
    case movies = "Movies"
    case tvShows = "TV"
}

@Observable
class SearchViewModel {
    private(set) var errorMessage: String?
    private(set) var searchTitles: [Title] = []
    private(set) var searchPeople: [PersonSearchItem] = []
    private let dataFetcher = DataFetcher()

    func getSearchTitles(by media: String, for title: String) async {
        do {
            errorMessage = nil
            if title.isEmpty {
                searchTitles = try await dataFetcher.fetchTitles(for:media, by: "trending")
            } else {
                searchTitles = try await dataFetcher.fetchTitles(for:media, by: "search", with: title)
            }
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }

    func getSearchPeople(for query: String) async {
        do {
            errorMessage = nil
            searchPeople = try await dataFetcher.fetchPeople(for: query)
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
}
