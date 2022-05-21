//
//  FeedModel.swift
//  Challenge5
//
//  Created by Bagas Ilham on 09/05/22.
//

import Foundation

struct FeedModel: Codable {
    let id: String
    let image: String
    let likes: Int
    let tags: [String]
    let text: String
    let publishDate: String
    let owner: FeederModel
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case image = "image"
        case likes = "likes"
        case tags = "tags"
        case text = "text"
        case publishDate = "publishDate"
        case owner = "owner"
    }
}
