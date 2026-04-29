//
//  TitleDetailView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/1/26.
//

import SwiftUI
import SwiftData

struct TitleDetailView: View {
    @Environment(\.dismiss) var dismiss
    let title: Title
    var showWatchlistButton: Bool = true
    var titleName : String {
        return(title.name ?? title.title) ?? ""
    }
    private var isInWatchlist: Bool {
        guard let titleId = title.id else { return false }
        return savedTitles.contains(where: { $0.id == titleId })
    }
    private var savedTitle: Title? {
        guard let titleId = title.id else { return nil }
        return savedTitles.first(where: { $0.id == titleId })
    }
    let viewModel = ViewModel()
    @Environment(\.modelContext) var modelContext
    @Query private var savedTitles: [Title]
    
    var body: some View {
        GeometryReader{ geometry in
            switch viewModel.videoIdStatus {
            case .notStarted:
                EmptyView()
            case .fetching:
                ProgressView()
                    .frame(width:geometry.size.width, height:geometry.size.height)
            case .success:
                ScrollView{
                    LazyVStack(alignment: .leading){
                        YoutubePlayer(videoID: viewModel.videoId)
                            .aspectRatio(1.3, contentMode: .fit)
                        
                        HStack {
                            Text(titleName)
                                .bold()
                                .font(.title2)
                                
                            Spacer()
                            
                            Button {
                                if let exsiting = savedTitle {
                                    exsiting.isFavorite.toggle()
                                    try? modelContext.save()
                                } else {
                                    let newTitle = Title(
                                        id: title.id,
                                        title: titleName,
                                        name: title.name,
                                        overview: title.overview,
                                        posterPath: title.posterPath,
                                        mediaType: title.mediaType,
                                        isFavorite: true
                                    )
                                    modelContext.insert(newTitle)
                                    try? modelContext.save()
                                }
                            } label : {
                                Image(systemName: (savedTitle?.isFavorite ?? false) ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundStyle((savedTitle?.isFavorite ?? false) ? .red : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(5)
        
                        Text(title.overview ?? "")
                            .padding(5)
                        
                        // MARK: - Genres + Rating
                        if !viewModel.genres.isEmpty {
                            HStack {
                                ForEach(viewModel.genres) { genre in
                                    Text(genre.name)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                    Text(String(format: "%.1f", viewModel.voteAverage))
                                        .bold()
                                }
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                        }
                        
                        // MARK: - Top Billed Cast
                        if !viewModel.cast.isEmpty {
                            VStack(alignment: .leading) {
                                Text(Constants.castHeaderString)
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal, 5)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(viewModel.cast) { member in
                                            NavigationLink(value: member) {
                                                VStack {
                                                    if let profilePath = member.profilePath {
                                                        AsyncImage(url: URL(string: Constants.profileImageURLStart + profilePath)) { image in
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                        } placeholder: {
                                                            Image(systemName: "person.circle.fill")
                                                                .resizable()
                                                                .foregroundStyle(.gray)
                                                        }
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(Circle())
                                                    } else {
                                                        Image(systemName: "person.circle.fill")
                                                            .resizable()
                                                            .foregroundStyle(.gray)
                                                            .frame(width: 80, height: 80)
                                                    }
                                                    
                                                    Text(member.name)
                                                        .font(.caption)
                                                        .bold()
                                                        .lineLimit(1)
                                                    
                                                    Text(member.character ?? "")
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(1)
                                                }
                                                .frame(width: 90)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // MARK: - Where to Watch
                        if let providers = viewModel.watchProviders {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(Constants.watchProvidersHeaderString)
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal, 5)

                                if let streaming = providers.flatrate, !streaming.isEmpty {
                                    providerRow(label: "Stream", providers: streaming)
                                }
                                if let rental = providers.rent, !rental.isEmpty {
                                    providerRow(label: "Rent", providers: rental)
                                }
                                if let purchase = providers.buy, !purchase.isEmpty {
                                    providerRow(label: "Buy", providers: purchase)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // MARK: - More Like This
                        if !viewModel.similarTitles.isEmpty {
                            VStack(alignment: .leading) {
                                Text(Constants.similarHeaderString)
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal, 5)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 12) {
                                        ForEach(viewModel.similarTitles) { similarTitle in
                                            NavigationLink(value: Title(
                                                id: similarTitle.id,
                                                title: similarTitle.title,
                                                name: similarTitle.name,
                                                overview: similarTitle.overview,
                                                posterPath: Constants.posterURLStart + (similarTitle.posterPath ?? ""),
                                                mediaType: similarTitle.mediaType ?? title.mediaType ?? "movie"
                                            )) {
                                                AsyncImage(url: URL(string: Constants.posterURLStart + (similarTitle.posterPath ?? ""))) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: 120, height: 180)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            case .failed(let underlyingError):
                Text(underlyingError.localizedDescription)
                    .errorMessage()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .task {
            if let titleId = title.id {
                let mediaType = title.mediaType ?? "movie"
                async let videoFetch: () = viewModel.getVideoId(for: titleId, mediaType: mediaType)
                async let detailFetch: () = viewModel.getTitleDetail(for: titleId, mediaType: mediaType)
                _ = await (videoFetch, detailFetch)
            }
        }
            .toolbar {
                if showWatchlistButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let existing = savedTitle {
                                existing.isBookmarked.toggle()
                                if !existing.isBookmarked && !existing.isFavorite {
                                    modelContext.delete(existing)
                                }
                                try? modelContext.save()
                            } else {
                                let newTitle = Title(
                                    id: title.id,
                                    title: titleName,
                                    name: title.name,
                                    overview: title.overview,
                                    posterPath: title.posterPath,
                                    mediaType: title.mediaType,
                                    isBookmarked: true
                                )
                                modelContext.insert(newTitle)
                                try? modelContext.save()
                            }
                        } label: {
                            Image(systemName: (savedTitle?.isBookmarked ?? false) ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                        }
                    }
                }
            }
        }   // ← line 214, end of body
    }
    
    @ViewBuilder
    private func providerRow(label: String, providers: [WatchProvider]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(providers) { provider in
                        VStack {
                            if let logoPath = provider.logoPath {
                                AsyncImage(url: URL(string: Constants.logoImageURLStart + logoPath)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.gray.opacity(0.3))
                                }
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 48, height: 48)
                            }

                            Text(provider.providerName)
                                .font(.caption2)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 60)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
#Preview {
    TitleDetailView(title: Title.previewTitles[0])
}
