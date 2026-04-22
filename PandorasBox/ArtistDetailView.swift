//
//  ArtistDetailView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/22/26.
//

import SwiftUI

struct ArtistDetailView: View {
    let castMember: CastMember
    let viewModel = ViewModel()
    
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
                        }
                        .padding(.horizontal)
                        
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
                        if let detail = viewModel.personDetail {
                            HStack(alignment: .top, spacing: 12) {
                                if let profilePath = detail.profilePath {
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
                                Text(detail.biography ?? "No biography available")
                                    .font(.body)
                                    .lineLimit(8)
                            }
                            .padding(.horizontal)
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
    }
}
