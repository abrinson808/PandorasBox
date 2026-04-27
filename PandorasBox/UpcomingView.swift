//
//  UpcomingView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/5/26.
//

import SwiftUI

struct UpcomingView: View {
    let viewModel = ViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geo in
                switch viewModel.upcomingStatus {
                case .notStarted:
                    EmptyView()
                case .fetching:
                    ProgressView()
                        .frame(width: geo.size.width, height: geo.size.height)
                case .success:
                    VerticalListView(titles: viewModel.upcomingMovies, canDelete: false)
                case .failed(let underlyingError):
                    Text(underlyingError.localizedDescription)
                        .errorMessage()
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .navigationTitle("What's Next?")
            .task {
                await viewModel.getUpcomingMovies()
            }
            .navigationDestination(for: Title.self) { title in
                TitleDetailView(title: title)
            }
            .navigationDestination(for: CastMember.self) { member in
            ArtistDetailView(castMember: member)
            }
        }
    }
}

#Preview {
    UpcomingView()
}
