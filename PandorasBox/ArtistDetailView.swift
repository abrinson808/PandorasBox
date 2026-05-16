//
//  ArtistDetailView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/22/26.
//

import SwiftUI

struct ArtistDetailView: View {
    let castMember: CastMember
    @State private var viewModel = ViewModel()
    @State private var showFullBio = false

    var body: some View {
        GeometryReader { geometry in
            switch viewModel.personDetailStatus {
            case .notStarted:
                EmptyView()
            case .fetching:
                ProgressView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            case .success:
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.personDetail?.name ?? castMember.name)
                                .font(.title)
                                .bold()

                            Text(viewModel.personDetail?.knownForDepartment ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let birthday = viewModel.personDetail?.birthday {
                                Text("Born: \(birthday)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let birthplace = viewModel.personDetail?.placeOfBirth {
                                Text(birthplace)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        
                        if let detail = viewModel.personDetail {
                            HStack(alignment: .top, spacing: 12) {
                                if let profilePath = detail.profilePath {
                                    NavigationLink {
                                        PersonImagesView(
                                            name: detail.name,
                                            images: viewModel.personImages
                                        )
                                    } label: {
                                        AsyncImage(url: URL(string: Constants.profileImageURLStart + profilePath)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundStyle(.gray)
                                        }
                                        .frame(width: 120, height: 160)
                                        .clipShape(RoundedRectangle(cornerRadius:10))
                                    }
                                    .buttonStyle(.plain)
                                }
                                Button {
                                    showFullBio = true
                                } label: {
                                    Text(detail.biography ?? "No biography available")
                                        .font(.body)
                                        .lineLimit(8)
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(.primary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                        }
                        if !viewModel.personVideoId.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                if let credit = viewModel.mostRecentCredit {
                                    Text("Latest: \(credit.displayName)")
                                        .font(.headline)
                                        .padding(.horizontal)
                                }
                                YoutubePlayer(videoID: viewModel.personVideoId)
                                    .aspectRatio(1.3, contentMode: .fit)
                            }
                        }
                        if !viewModel.personCredits.isEmpty {
                                                    VStack(alignment: .leading, spacing: 12) {
                                                        Text("Known For")
                                                            .font(.title2)
                                                            .bold()
                                                            .padding(.horizontal)

                                                        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 12) {
                                                            ForEach(viewModel.personCredits.prefix(9)) { credit in
                                                                NavigationLink(value: Title(
                                                                    id: credit.id,
                                                                    title: credit.title,
                                                                    name: credit.name,
                                                                    overview: credit.overview,
                                                                    posterPath: Constants.posterURLStart + (credit.posterPath ?? ""),
                                                                    mediaType: credit.mediaType ?? "movie"
                                                                )) {
                                                                    VStack {
                                                                        AsyncImage(url: URL(string: Constants.posterURLStart + (credit.posterPath ?? ""))) { image in
                                                                            image
                                                                                .resizable()
                                                                                .scaledToFill()
                                                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                                        } placeholder: {
                                                                            RoundedRectangle(cornerRadius: 10)
                                                                                .fill(.gray.opacity(0.2))
                                                                        }
                                                                        .frame(height: 160)
                                                                        .clipShape(RoundedRectangle(cornerRadius: 10))

                                                                        Text(credit.displayName)
                                                                            .font(.caption)
                                                                            .lineLimit(1)
                                                                    }
                                                                }
                                                                .buttonStyle(.plain)
                                                            }
                                                        }
                                                        .padding(.horizontal)

                                                        if viewModel.personCredits.count > 9 {
                                                            NavigationLink {
                                                                PersonFilmographyView(
                                                                    name: viewModel.personDetail?.name ?? castMember.name,
                                                                    credits: viewModel.personCredits
                                                                )
                                                            } label: {
                                                                Text("See More")
                                                                    .font(.subheadline)
                                                                    .bold()
                                                            }
                                                            .padding(.horizontal)
                                                        }
                                                    }
                                                    .padding(.vertical, 8)
                                                }

                                                if !viewModel.relatedArtists.isEmpty {
                                                    VStack(alignment: .leading) {
                                                        Text("You Might Also Like")
                                                            .font(.title2)
                                                            .bold()
                                                            .padding(.horizontal)

                                                        ScrollView(.horizontal, showsIndicators: false) {
                                                            LazyHStack(spacing: 16) {
                                                                ForEach(viewModel.relatedArtists) { artist in
                                                                    NavigationLink(value: artist) {
                                                                        VStack {
                                                                            if let profilePath = artist.profilePath {
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

                                                                            Text(artist.name)
                                                                                .font(.caption)
                                                                                .bold()
                                                                                .lineLimit(1)

                                                                            Text(artist.character ?? "")
                                                                                .font(.caption2)
                                                                                .foregroundStyle(.secondary)
                                                                                .lineLimit(1)
                                                                        }
                                                                        .frame(width: 90)
                                                                    }
                                                                    .buttonStyle(.plain)
                                                                }
                                                            }
                                                            .padding(.horizontal)
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
            await viewModel.getPersonDetail(for: castMember.id)
        }
        .navigationDestination(for: Title.self) { title in
            TitleDetailView(title: title)
        }
        .navigationDestination(for: CastMember.self) { member in
            ArtistDetailView(castMember: member)
        }
        .sheet(isPresented: $showFullBio) {
            NavigationStack {
                ScrollView {
                    Text(viewModel.personDetail?.biography ?? "No biography available")
                        .font(.body)
                        .padding()
                }
                .navigationTitle("Biography")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showFullBio = false }
                    }
                }
            }
        }
    }
}

private struct PersonFilmographyView: View {
    let name: String
    let credits: [PersonCredit]

    var body: some View {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 12) {
                    ForEach(credits) { credit in
                        NavigationLink(value: Title(
                            id: credit.id,
                            title: credit.title,
                            name: credit.name,
                            overview: credit.overview,
                            posterPath: Constants.posterURLStart + (credit.posterPath ?? ""),
                            mediaType: credit.mediaType ?? "movie"
                        )) {
                            VStack {
                                AsyncImage(url: URL(string: Constants.posterURLStart + (credit.posterPath ?? ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.gray.opacity(0.2))
                                }
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                Text(credit.displayName)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(name)
                    .navigationDestination(for: Title.self) { title in
                        TitleDetailView(title: title)
            }
        }
}

private struct PersonImagesView: View {
    let name: String
    let images: [PersonImage]

    var body: some View {
        ScrollView {
            if images.isEmpty {
                ContentUnavailableView(
                    "No Photos Available",
                    systemImage: "photo.on.rectangle",
                    description: Text("This artist doesn't have any additional photos on file.")
                )
                .padding(.top, 60)
            } else {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                    ForEach(images) { image in
                        AsyncImage(url: URL(string: Constants.profileImageURLStart + image.filePath)) { img in
                            img
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.opacity(0.2))
                        }
                        .aspectRatio(image.aspectRatio, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("\(name) — Photos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
