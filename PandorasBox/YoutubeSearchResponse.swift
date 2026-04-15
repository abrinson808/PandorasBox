//
//  YoutubeSearchResponse.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/2/26.
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [ItemProperties]?
}

struct ItemProperties: Codable {
    let id: IdProperties?
}

struct IdProperties: Codable {
    let videoId: String?
}
