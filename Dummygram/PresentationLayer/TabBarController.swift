//
//  TabBarController.swift
//  Dummygram
//
//  Created by Bagas Ilham on 09/05/22.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tabBar.tintColor = .label
        tabBar.isTranslucent = true

        let feedsController = FeedsController()
        let feedsAPI = DummyAPI(query: "/post")
        feedsController.API = feedsAPI
        feedsController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let browseViewController = BrowseViewController()
        let browseAPI = DummyAPI(query: "/post?page=1&limit=40")
        browseViewController.API = browseAPI
        browseViewController.tabBarItem = UITabBarItem(
            title: "Browse",
            image: UIImage(systemName: "square.stack"),
            selectedImage: UIImage(systemName: "square.stack.fill")
        )
        
        let usersListController = UsersListController()
        let usersAPI = DummyAPI(query: "/user")
        usersListController.API = usersAPI
        usersListController.tabBarItem = UITabBarItem(
            title: "DummyAPI.io",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )

        let _viewControllers: [UINavigationController] = [
            feedsController, browseViewController, usersListController
        ].map { UINavigationController(rootViewController: $0) }
        
        viewControllers = _viewControllers
        
    }
}