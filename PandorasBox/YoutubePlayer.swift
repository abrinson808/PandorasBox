//
//  YoutubePlayer.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/1/26.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct YoutubePlayer: View {
    let videoID: String
    @State private var showTrailer = false

    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Rectangle()
                    .fill(.black)
                    .overlay { ProgressView() }
            }

            Button {
                showTrailer = true
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(radius: 5)
            }
        }
        .fullScreenCover(isPresented: $showTrailer) {
            if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}
