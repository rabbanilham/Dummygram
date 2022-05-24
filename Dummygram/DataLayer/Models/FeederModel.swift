//
//  FeederModel.swift
//  Challenge5
//
//  Created by Bagas Ilham on 09/05/22.
//

import Foundation

struct FeederModel: Codable {
    let id: String
    let title: String
    let firstName: String
    let lastName: String
    let picture: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case firstName = "firstName"
        case lastName = "lastName"
        case picture = "picture"
    }
}
