//
//  Title.swift
//  PandorasBox
//
//  Created by Alex Brinson on 3/31/26.
//

import SwiftData

struct TMDBAPIObject: Decodable {
    var results: [Title] = []
}

@Model
class Title: Decodable, Identifiable, Hashable {
    @Attribute(.unique)
    var id: Int?
    var title: String?
    var name: String?
    var overview: String?
    var posterPath: String?
    
    init(id: Int?, title: String?, name: String?, overview: String?, posterPath: String?) {
        self.id = id
        self.title = title
        self.name = name
        self.overview = overview
        self.posterPath = posterPath
    }
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case name
        case overview
        case posterPath
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
    }
    
    static var previewTitles = [
        Title(id: 1, title: "Project Hail Mary", name: "Project Hail Mary", overview: "Science teacher Ryland Grace wakes up on a spaceship light years from home with no recollection of who he is or how he got there. As his memory returns, he begins to uncover his mission: solve the riddle of the mysterious substance causing the sun to die out. He must call on his scientific knowledge and unorthodox ideas to save everything on Earth from extinction… but an unexpected friendship means he may not have to do it alone.", posterPath: Constants.testTitleURL),
        Title(id: 2, title: "They Will Kill You", name: "They Will Kill You", overview: "A woman answers a help wanted ad to be a housekeeper in a mysterious high-rise in New York City, not realizing she is entering a community that has seen a number of disappearances over the years and may be under the grip of a Satanic cult.", posterPath: Constants.testTitleURL2),
        Title(id: 3, title: "Gunpowder Milkshake", name: "Gunpowder Milkshake", overview: "To protect an 8-year-old girl, a dangerous assassin reunites with her mother and her lethal associates to take down a ruthless crime syndicate and its army of henchmen.", posterPath: Constants.testTitleURL3)
    ]
}
