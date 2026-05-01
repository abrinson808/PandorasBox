//
//  SerachView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/5/26.
//

import SwiftUI

struct SearchView: View {
    @State private var searchByMovies = true
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
                
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(searchViewModel.searchTitles){ title in
                        AsyncImage(url: URL(string: title.posterPath ?? "")) {image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(.rect(cornerRadius: 10))
                        }placeholder: {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.opacity(0.2))
                        }
                        .frame(width: 120, height: 200)
                        .clipShape(.rect(cornerRadius: 10))
                        .onTapGesture {
                            navigationPath.append(title)
                        }
                    }
                }
            }
            .refreshable {
                let media = searchByMovies ? "movie" : "tv"
                let query = searchText
                await searchViewModel.getSearchTitles(by: media, for: query)
            }
            .navigationTitle(searchByMovies ? Constants.movieSearchString : Constants.tvSearchString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        searchByMovies.toggle()
                        
                        Task{
                            await searchViewModel.getSearchTitles(by: searchByMovies ? "movie" : "tv", for: searchText)
                        }
                        
                    } label: {
                        Image(systemName: searchByMovies ? Constants.movieIconString : Constants.tvIconString)
                    }
                }
            }
            .searchable(text: $searchText, prompt: searchByMovies ? Constants.moviePlaceholderString : Constants.tvPlaceholderString)
            .task(id: searchText) {
                try? await Task.sleep(for: .milliseconds(500))
                
                if Task.isCancelled{
                    return
                }
                
                await searchViewModel.getSearchTitles(by: searchByMovies ? "movie" : "tv", for: searchText)
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
