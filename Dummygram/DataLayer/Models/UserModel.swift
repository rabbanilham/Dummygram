//
//  InstagramUser.swift
//  Challenge5
//
//  Created by Bagas Ilham on 28/04/22.
//

import Foundation

struct UserShortModel: Codable {
    let id: String
    let title: String
    let firstName: String
    let lastName: String
    let picture: String
}

struct UserModel: Codable {
    let id: String
    let title: String
    let firstName: String
    let lastName: String
    let picture: String
    let gender: String
    let email: String
    let dateOfBirth: String
    let phone: String
    let location: LocationModel
    let registerDate: String
    let updatedDate: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case firstName = "firstName"
        case lastName = "lastName"
        case picture = "picture"
        case gender = "gender"
        case email = "email"
        case dateOfBirth = "dateOfBirth"
        case phone = "phone"
        case location = "location"
        case registerDate = "registerDate"
        case updatedDate = "updatedDate"
    }
}

struct LocationModel: Codable {
    let street: String
    let city: String
    let state: String
    let country: String
    let timezone: String
    
    enum CodingKeys: String, CodingKey {
        case street = "street"
        case city = "city"
        case state = "state"
        case country = "country"
        case timezone = "timezone"
    }
}
