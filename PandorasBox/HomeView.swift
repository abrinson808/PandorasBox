//
//  HomeView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 3/31/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @State private var viewModel = ViewModel()
    @State private var titleDetailPath = NavigationPath()
    @State private var heroIndex = 0
    @State private var heroTimer: Timer?
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack(path: $titleDetailPath) {
            GeometryReader {geo in
                ScrollView(.vertical) {
                    switch viewModel.homeStatus {
                    case .notStarted:
                        EmptyView()
                    case .fetching:
                        ProgressView()
                            .frame(width: geo.size.width, height: geo.size.height)
                    case .success:
                        LazyVStack{
                            HeroCarousel(
                                titles: viewModel.heroTitles,
                                width: geo.size.width,
                                height: geo.size.height * 0.85,
                                heroIndex: $heroIndex,
                                heroTimer: $heroTimer,
                                onTap: { titleDetailPath.append($0) }
                            )
                            
                            HorizontalListView(header: Constants.nowPlayingString, titles: viewModel.nowPlaying) { title in
                                titleDetailPath.append(title)
                            }
                            
                            HorizontalListView(header: Constants.trendingMoviesString, titles: viewModel.trendingMovies) { title in
                                titleDetailPath.append(title)
                            }
                            HorizontalListView(header: Constants.trendingTVString, titles: viewModel.trendingTV) { title in
                                titleDetailPath.append(title)
                            }
                        }
                      
                    case .failed (let error):
                        Text(error.localizedDescription)
                            .errorMessage()
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .refreshable {
                    async let fetch: () = viewModel.refreshTitles()
                    async let delay: () = Task.sleep(for: .seconds(0.8))
                    _ = try? await (fetch, delay)
                }
                .task{
                    await viewModel.getTitles()
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
}

#Preview {
    HomeView()
}
private struct HeroCarousel: View {
    let titles: [Title]
    let width: CGFloat
    let height: CGFloat
    @Binding var heroIndex: Int
    @Binding var heroTimer: Timer?
    let onTap: (Title) -> Void

    var body: some View {
        TabView(selection: $heroIndex) {
            ForEach(Array(titles.prefix(6).enumerated()), id: \.offset) { index, title in
                AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .overlay {
                            LinearGradient(
                                stops: [Gradient.Stop(color: .clear, location: 0.8),
                                        Gradient.Stop(color: .gradient, location: 1)],
                                startPoint: .top,
                                endPoint: .bottom)
                        }
                } placeholder: {
                    ProgressView()
                }
                .frame(width: width, height: height)
                .onTapGesture { onTap(title) }
                .accessibilityLabel((title.name ?? title.title) ?? "Featured Title")
                .accessibilityHint("Show details")
                .accessibilityAddTraits(.isButton)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(width: width, height: height)
        .onAppear {
            heroTimer = Timer.scheduledTimer(withTimeInterval: 22, repeats: true) { _ in
                withAnimation {
                    let count = min(titles.count, 6)
                    if count > 0 {
                        heroIndex = (heroIndex + 1) % count
                    }
                }
            }
        }
        .onDisappear {
            heroTimer?.invalidate()
            heroTimer = nil
        }
    }
}
