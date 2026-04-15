//
//  YoutubeSearchResponse.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/2/26.
//

import Foundation

struct TMDBVideoResponse: Codable {
    let results: [TMDBVideo]
}

struct TMDBVideo: Codable {
    let key: String
    let site: String
    let type: String
}
