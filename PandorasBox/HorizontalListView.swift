//
//  HorizontalListView.swift
//  PandorasBox
//
//  Created by Alex Brinson on 3/31/26.
//

import SwiftUI

struct HorizontalListView: View {
    let header : String
    var titles : [Title]
    let onSelect: (Title) -> Void
    
    var body: some View {
        VStack(alignment: .leading){
            Text(header)
                .font(.title)
            
            ScrollView (.horizontal) {
                LazyHStack {
                    ForEach(titles) {title in
                        Button {
                            onSelect(title)
                        } label: {
                            AsyncImage(url: URL(string: title.posterPath ?? "")){image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 200)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel((title.name ?? title.title) ?? "Untitled")
                        .accessibilityHint("Shows details")
                    }
                }
            }
        }
        .frame(height: 250)
        .padding(10)
    }
}

#Preview {
    HorizontalListView(header: Constants.trendingMoviesString, titles: Title.previewTitles) {title in
        
    }
}
