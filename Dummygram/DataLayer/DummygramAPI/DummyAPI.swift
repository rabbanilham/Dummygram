//
//  UserManager.swift
//  Challenge5
//
//  Created by Bagas Ilham on 02/05/22.
//

import Foundation
import Alamofire

struct DummyAPI {
    
    let baseURL = "https://dummyapi.io/data/v1"
    
    func getFeed(
        feedId: String,
        completionHandler: @escaping (FeedModel?, AFError?) -> Void
    ) {
        let query = "/post/\(feedId)"
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
                
        AF.request(baseURL + query, headers: headers)
            .validate()
            .responseDecodable(of: FeedModel.self) { (response) in
                switch response.result {
                case let .success(data):
                    completionHandler(data, nil)
                case let .failure(error):
                    completionHandler(nil, error)
                    print(String(describing: error))
                }
            }
    }
    
    func getFeeds(
        page: Int,
        limit: Int,
        completionHandler: @escaping (DataModel<FeedModel>?, AFError?) -> Void
    ) {
        let query = "/post?page=\(page)&limit=\(limit)"
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
                
        AF.request(baseURL + query, headers: headers)
            .validate()
            .responseDecodable(of: DataModel<FeedModel>.self) { (response) in
                switch response.result {
                case let .success(data):
                    completionHandler(data, nil)
                case let .failure(error):
                    completionHandler(nil, error)
                    print(String(describing: error))
                }
            }
    }
    
    func getUsers(
        page: Int,
        limit: Int,
        completionHandler: @escaping (DataModel<UserShortModel>?, AFError?) -> Void
    ) {
        let query = "/user?page=\(page)&limit=\(limit)"
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
                
        AF.request(baseURL + query, headers: headers)
            .validate()
            .responseDecodable(of: DataModel<UserShortModel>.self) { (response) in
                switch response.result {
                case let .success(data):
                    completionHandler(data, nil)
                case let .failure(error):
                    completionHandler(nil, error)
                    print(String(describing: error))
                }
            }
    }
    
    func getUserDetail(
        userId: String,
        completionHandler: @escaping (UserModel?, AFError?) -> Void
    ) {
        let query = "/user/\(userId)"
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
                
        AF.request(baseURL + query, headers: headers)
            .validate()
            .responseDecodable(of: UserModel.self) { (response) in
                switch response.result {
                case let .success(data):
                    completionHandler(data, nil)
                case let .failure(error):
                    completionHandler(nil, error)
                    print(String(describing: error))
                }
            }
    }
    
    func getFeedComments(
        postId: String,
        completionHandler: @escaping (DataModel<CommentModel>?, AFError?) -> Void
    ) {
        let query = "/post/\(postId)/comment"
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
        
        AF.request(baseURL + query, headers: headers)
            .validate()
            .responseDecodable(of: DataModel<CommentModel>.self) { (response) in
                switch response.result {
                case let .success(data):
                    completionHandler(data, nil)
                case let .failure(error):
                    completionHandler(nil, error)
                    print(String(describing: error))
                }
        }
    }
    
    func addFeed(
        text: String,
        image: String,
        likes: Int?,
        tags: [String]?,
        owner: String
    ) {
        let query = "/post/create"
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
        
        let parameters: Parameters = [
            "text" : text,
            "image" : image,
            "likes" : likes ?? Int.random(in: 1...1000),
            "tags" : tags ?? [],
            "owner" : owner
        ]
        
        AF.request(baseURL + query, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                print(response)
            }
    }
    
    func addComment(
        comment: String,
        ownerId: String,
        postId: String
    ) {
        let query = "/comment/create"
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
        
        let parameters: Parameters = [
            "message" : comment,
            "owner" : ownerId,
            "post" : postId
        ]
        
        AF.request(baseURL + query, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                print(response)
            }
    }
    
    func deleteComment(
        commentId: String
    ) {
        let query = "/comment/\(commentId)"
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
        
        AF.request(baseURL + query, method: .delete, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                print(response)
            }
    }
}
