//
//  CommentModel.swift
//  Dummygram
//
//  Created by Bagas Ilham on 20/05/22.
//

import Foundation

struct CommentModel: Codable {
    let id, message: String
    let owner: UserShortModel
    let post, publishDate: String
}
