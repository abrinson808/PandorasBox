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
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // MARK: - Coming Soon (horizontal scroll)
                                if !viewModel.comingSoonMovies.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 12) {
                                            ForEach(viewModel.comingSoonMovies) { title in
                                                NavigationLink(value: title) {
                                                    VStack {
                                                        AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                                                            image
                                                                .resizable()
                                                                .scaledToFit()
                                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        } placeholder: {
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(.gray.opacity(0.2))
                                                        }
                                                        .frame(width: 120, height: 180)

                                                        Text((title.name ?? title.title) ?? "")
                                                            .font(.caption)
                                                            .lineLimit(1)
                                                    }
                                                    .frame(width: 120)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }

                                // MARK: - What's Next (compact scrollable list)
                                Text("What's Next?")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)

                                List {
                                    ForEach(viewModel.upcomingMixed) { title in
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
                                                .frame(width: 50, height: 75)
                                                .clipShape(RoundedRectangle(cornerRadius: 6))

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text((title.name ?? title.title) ?? "Untitled")
                                                        .font(.subheadline)
                                                        .bold()
                                                        .lineLimit(2)

                                                    Text(title.mediaType == "tv" ? "TV Show" : "Movie")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                                .listStyle(.plain)
                                .frame(height: 270)
                                .scrollContentBackground(.hidden)
                            }
                        }
                    case .failed(let underlyingError):
                        Text(underlyingError.localizedDescription)
                            .errorMessage()
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                .navigationTitle(Constants.comingSoonTVString)
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
