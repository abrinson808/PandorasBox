//
//  DownloadView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/12/26.
//

import SwiftUI
import SwiftData

struct WatchlistView: View {
    @Query(sort: \Title.title) var savedTitles: [Title]
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath){
            if savedTitles.isEmpty {
                Text("Your Watchlist is Empty")
                    .padding()
                    .font(.title3)
                    .bold()
            } else {
                VerticalListView(titles: savedTitles, canDelete: true)
            }
        }
    }
}

#Preview {
    WatchlistView()
}
