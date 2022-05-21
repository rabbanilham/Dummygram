//
//  UserDefaultHelper.swift
//  Dummygram
//
//  Created by Bagas Ilham on 09/05/22.
//

import Foundation

final class UserDefaultsHelper {
    static let standard = UserDefaultsHelper()
    
    private init() {
    }
    
    var feeds: [FeedModel] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "feeds") else {
                return []
            }
            let res = try? data.decode(to: [FeedModel].self)
            return res ?? []
        }
        set(newValue) {
            guard let data = try? newValue.encode() else { return }
            UserDefaults.standard.set(data, forKey: "feeds")
        }
    }
    
    var collections: [FeedModel] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "collections") else {
                return []
            }
            let res = try? data.decode(to: [FeedModel].self)
            return res ?? []
        }
        set(newValue) {
            guard let data = try? newValue.encode() else { return }
            UserDefaults.standard.set(data, forKey: "collections")
        }
    }
    
    var usersList: [UserShortModel] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "users") else {
                return []
            }
            let res = try? data.decode(to: [UserShortModel].self)
            return res ?? []
        }
        set(newValue) {
            guard let data = try? newValue.encode() else { return }
            UserDefaults.standard.set(data, forKey: "users")
        }

    }
    
    var loggedUser: String {
        get {
            guard let data = UserDefaults.standard.data(forKey: "logged-user") else {
                return ""
            }
            let res = try? data.decode(to: String.self)
            return res ?? ""
        }
        set(newValue) {
            guard let data = try? newValue.encode() else { return }
            UserDefaults.standard.set(data, forKey: "logged-user")
        }

    }
}
