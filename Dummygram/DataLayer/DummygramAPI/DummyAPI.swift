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
    var query: String
    
    init (query: String) {
        self.query = query
    }
    
    func getFeed(
        completionHandler: @escaping (FeedModel?, AFError?) -> Void
    ) {
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
        completionHandler: @escaping (DataModel<FeedModel>?, AFError?) -> Void
    ) {
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
        completionHandler: @escaping (DataModel<UserShortModel>?, AFError?) -> Void
    ) {
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
        completionHandler: @escaping (UserModel?, AFError?) -> Void
    ) {
        
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
    
    func addComment(comment: String, ownerId: String, postId: String) {
        
        let headers: HTTPHeaders = [
            "app-id" : "625534f6d7e95833f9570907",
        ]
        
        let parameters: Parameters = [
            "message" : comment,
            "owner" : ownerId,
            "post" : postId
        ]
        
        AF.request(baseURL + "/comment/create", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                print(response)
            }
    }
    
    func deleteComment() {
        
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
