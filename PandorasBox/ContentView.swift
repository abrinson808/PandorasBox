//
//  ContentView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 3/31/26.
//

import SwiftUI

enum AppTab: Hashable {
    case home, upcoming, watchlist, search
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(Constants.homeString, systemImage: Constants.homeIconString, value: .home) {
                HomeView()
            }
            Tab(Constants.upcomingString, systemImage: Constants.upcomingIconString, value: .upcoming) {
                UpcomingView()
            }
            Tab(Constants.watchlistString, systemImage: Constants.watchlistIconString, value: .watchlist) {
                WatchlistView(selectedTab: $selectedTab)
            }
            Tab(value: .search, role: .search) {
                SearchView()
            }
        }
    }
}

#Preview {
    ContentView()
}
