//
//  PersonDetailResponse.swift
//  PandorasBox
//
//  Created by Alex Brinson on 4/22/26.
//

import Foundation

struct PersonDetailResponse: Decodable {
    let id: Int
    let name: String
    let biography: String?
    let knownForDepartment: String?
    let profilePath: String?
    let birthday: String?
    let placeOfBirth: String?
    let combinedCredits: CombinedCredits
}

struct CombinedCredits: Decodable {
    let cast: [PersonCredit]?
    let crew: [PersonCredit]?
}

struct PersonCredit: Decodable, Identifiable {
    let id: Int
    let title: String?
    let name: String?
    let posterPath: String?
    let overview: String?
    let mediaType: String?
    let releaseDate: String?
    let firstAirDate: String?
    let character: String?
    
    var displayName: String {
        (name ?? title) ?? ""
    }
    var sortDate: String {
        releaseDate ?? firstAirDate ?? ""
    }
}
