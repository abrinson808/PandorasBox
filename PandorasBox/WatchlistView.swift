//
//  DownloadView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/12/26.
//

import SwiftUI
import SwiftData

struct WatchlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Title.title) private var savedTitles: [Title]
    @State private var navigationPath = NavigationPath()
    @State private var showFavorites = false
    let viewModel = ViewModel()

    private var watchMeTitles: [Title] {
        savedTitles.filter { $0.isBookmarked && !$0.isWatched }
    }

    private var alreadyWatchedTitles: [Title] {
        savedTitles.filter { $0.isBookmarked && $0.isWatched }
    }
    
    private var favoriteTitles: [Title] {
        savedTitles.filter { $0.isFavorite}
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if watchMeTitles.isEmpty && alreadyWatchedTitles.isEmpty {
                    Text("Your Watchlist is Empty")
                        .padding()
                        .font(.title3)
                        .bold()
                } else {
                    List {
                        Section("Watch Me!") {
                            if watchMeTitles.isEmpty {
                                Text("No titles waiting")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(watchMeTitles) { title in
                                    WatchlistRow(title: title)
                                }
                                .onDelete { offsets in
                                    deleteTitles(at: offsets, from: watchMeTitles)
                                }
                            }
                        }

                        Section("Already Watched") {
                            if alreadyWatchedTitles.isEmpty {
                                Text("Nothing marked watched yet")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(alreadyWatchedTitles) { title in
                                    WatchlistRow(title: title)
                                }
                                .onDelete { offsets in
                                    deleteTitles(at: offsets, from: alreadyWatchedTitles)
                                }
                            }
                        }

                        if !viewModel.suggestions.isEmpty {
                            Section("Suggestions for You") {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 12) {
                                        ForEach(viewModel.suggestions) { suggestion in
                                            NavigationLink(value: Title(
                                                id: suggestion.id,
                                                title: suggestion.title,
                                                name: suggestion.name,
                                                overview: suggestion.overview,
                                                posterPath: Constants.posterURLStart + (suggestion.posterPath ?? ""),
                                                mediaType: suggestion.mediaType ?? "movie"
                                            )) {
                                                AsyncImage(url: URL(string: Constants.posterURLStart + (suggestion.posterPath ?? ""))) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: 100, height: 150)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .listRowInsets(EdgeInsets())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Watchlist")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        showFavorites = true
                    } label: {
                        Image(systemName: favoriteTitles.isEmpty ? "heart" : "heart.fill")
                            .foregroundStyle(favoriteTitles.isEmpty ? Color.secondary : Color.red)
                    }
                }
            }
            .navigationDestination(isPresented: $showFavorites) {
                FavoritesListView(favorites: favoriteTitles)
            }
                .task(id: savedTitles.count) {
                    await viewModel.getSuggestions(from: savedTitles)
            }
            .navigationDestination(for: Title.self) { title in
                TitleDetailView(title: title, showWatchlistButton: false)
            }
            .navigationDestination(for: CastMember.self) { member in
                ArtistDetailView(castMember: member)
            }
        }
    }

    private func deleteTitles(at offsets: IndexSet, from titles: [Title]) {
        for offset in offsets {
            modelContext.delete(titles[offset])
        }
        try? modelContext.save()
    }
}

private struct WatchlistRow: View {
    let title: Title
    @Environment(\.modelContext) private var modelContext

    private var titleName: String {
        (title.name ?? title.title) ?? "Untitled"
    }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                title.isWatched.toggle()
                try? modelContext.save()
            } label: {
                Image(systemName: title.isWatched ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(title.isWatched ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title.isWatched ? "Mark as unwatched" : "Mark as watched")

            NavigationLink(value: title) {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.gray.opacity(0.25))
                            .overlay {
                                Image(systemName: "film")
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .frame(width: 40, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(titleName)
                            .font(.subheadline)
                            .strikethrough(title.isWatched)
                            .foregroundStyle(title.isWatched ? .secondary : .primary)
                            .lineLimit(2)

                        Text(title.mediaType == "tv" ? "TV Show" : "Movie")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private struct FavoritesListView: View {
    let favorites: [Title]

    var body: some View {
        Group {
            if favorites.isEmpty {
                ContentUnavailableView(
                    "No Favorites Yet",
                    systemImage: "heart.slash",
                    description: Text("Tap the heart on a title's detail page to add it here")
                )
            } else {
                List(favorites) { title in
                    NavigationLink(value: title) {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.gray.opacity(0.25))
                                    .overlay {
                                        Image(systemName: "film")
                                            .foregroundStyle(.secondary)
                                    }
                            }
                            .frame(width: 40, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                            VStack(alignment: .leading, spacing: 4) {
                                Text((title.name ?? title.title) ?? "Untitled")
                                    .font(.subheadline)
                                    .lineLimit(2)

                                Text(title.mediaType == "tv" ? "TV Show" : "Movie")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Favorites")
    }
}
#Preview {
    WatchlistView()
}
