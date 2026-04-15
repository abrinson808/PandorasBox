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
    var showDownloadButton: Bool = true
    var titleName : String {
        return(title.name ?? title.title) ?? ""
    }
    let viewModel = ViewModel()
    @Environment(\.modelContext) var modelContext
    
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
                        
                        Text(titleName)
                            .bold()
                            .font(.title2)
                            .padding(5)
                            
        
                        Text(title.overview ?? "")
                            .padding(5)
                        
                        if showDownloadButton{
                            HStack{
                                Spacer()
                                
                                Button {
                                    let saveTitle = title
                                    saveTitle.title = titleName
                                    modelContext.insert(saveTitle)
                                    try? modelContext.save()
                                    dismiss()
                                } label : {
                                    Text(Constants.downloadString)
                                        .ghostButton()
                                }
                                
                                Spacer()
                            }
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
                await viewModel.getVideoId(for: titleId, mediaType: title.mediaType ?? "movie")
            }
        }
    }
}

#Preview {
    TitleDetailView(title: Title.previewTitles[0])
}
