//
//  SerachView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/5/26.
//

import SwiftUI

struct SearchView: View {
    @State private var searchMode: SearchMode = .movies
    @State private var searchText = ""
    @State private var searchViewModel = SearchViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                if let error = searchViewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                }
                
                if !searchText.isEmpty && !searchViewModel.searchPeople.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("People")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(searchViewModel.searchPeople.prefix(10)) { person in
                                    Button {
                                        let member = CastMember(
                                            id: person.id,
                                            name: person.name,
                                            character: person.knownForDepartment,
                                            profilePath: person.profilePath,
                                            order: 0
                                        )
                                        navigationPath.append(member)
                                    } label: {
                                        VStack {
                                            if let profilePath = person.profilePath {
                                                AsyncImage(url: URL(string: Constants.profileImageURLStart + profilePath)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                } placeholder: {
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .foregroundStyle(.gray)
                                                }
                                                .frame(width: 70, height: 70)
                                                .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .foregroundStyle(.gray)
                                                    .frame(width: 70, height: 70)
                                            }
                                            
                                            Text(person.name)
                                                .font(.caption2)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 80)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(person.name)
                                    .accessibilityHint("Shows artist details")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(searchViewModel.searchTitles) { title in
                        Button {
                            navigationPath.append(title)
                        } label: {
                            AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(.rect(cornerRadius: 10))
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray.opacity(0.2))
                            }
                            .frame(width: 120, height: 200)
                            .clipShape(.rect(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel((title.name ?? title.title) ?? "Untitled")
                        .accessibilityHint("Shows details")
                    }
                }
            }
            .refreshable {
                let query = searchText
                let media = searchMode == .movies ? "movie" : "tv"
                await searchViewModel.getSearchTitles(by: media, for: query)
                if !query.isEmpty {
                    await searchViewModel.getSearchPeople(for: query)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Search Mode", selection: $searchMode) {
                        ForEach(SearchMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }
            }
            .searchable(text: $searchText, prompt: searchMode == .movies ? Constants.moviePlaceholderString : Constants.tvPlaceholderString)
            .task(id: "\(searchMode)\(searchText)") {
                try? await Task.sleep(for: .milliseconds(500))

                if Task.isCancelled {
                    return
                }

                let media = searchMode == .movies ? "movie" : "tv"
                await searchViewModel.getSearchTitles(by: media, for: searchText)
                if !searchText.isEmpty {
                    await searchViewModel.getSearchPeople(for: searchText)
                }
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
    SearchView()
}
