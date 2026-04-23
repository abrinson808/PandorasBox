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

    private var watchMeTitles: [Title] {
        savedTitles.filter { !$0.isWatched }
    }

    private var alreadyWatchedTitles: [Title] {
        savedTitles.filter { $0.isWatched }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if savedTitles.isEmpty {
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
                    }
                }
            }
            .navigationTitle("Watchlist")
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
                    .frame(width: 50, height: 74)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(titleName)
                            .font(.headline)
                            .strikethrough(title.isWatched)
                            .foregroundStyle(title.isWatched ? .secondary : .primary)
                            .lineLimit(2)

                        Text(title.mediaType == "tv" ? "TV Show" : "Movie")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    WatchlistView()
}
