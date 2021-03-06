//
//  UserFeedsController.swift
//  Challenge5
//
//  Created by Bagas Ilham on 09/05/22.
//

import UIKit
import Kingfisher

class UsersListController: UITableViewController {
    
    var API: DummyAPI?
    var displayedUsers: [UserShortModel] = []
    var defaultDisplayedUsers: [UserShortModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UserCell.self,
            forCellReuseIdentifier: "\(UserCell.self)"
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        
        setupNavigationBar()
        loadUsers()
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(UserCell.self)",
            for: indexPath
        ) as? UserCell else {
                return UITableViewCell()
            
        }
            
        let user = displayedUsers[indexPath.row]
        cell.setUser(with: user)
        return cell
        
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return displayedUsers.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let nav = UINavigationController()
        let vc = UserDetailViewController()
        nav.addChild(vc)
        let user = displayedUsers[indexPath.row]
        let API = DummyAPI()
        vc.userId = user.id
        vc.API = API
        vc.title = user.firstName.lowercased() + user.lastName.lowercased()
        navigationController?.showDetailViewController(nav, sender: Any.self)
    }
}

extension UsersListController {
    
    func setupNavigationBar() {
        title = "DummyAPI.io"
        let refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshUsers)
        )
        refreshButton.tintColor = .label
        navigationItem.leftBarButtonItem = refreshButton
        let searchController = UISearchController()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a user by name..."
        searchController.automaticallyShowsCancelButton = true
        searchController.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func loadUsers() {
        let randomPage: Int = Int.random(in: 0...1)
        let localUsers = UserDefaultsHelper.standard.usersList
        if !localUsers.isEmpty {
            self.displayedUsers = localUsers
            self.tableView.reloadData()
            return
        }
        API?.getUsers(
            page: randomPage,
            limit: 50,
            completionHandler: { [weak self] result, error in
            guard let _self = self else {return}
            _self.displayedUsers = result?.data ?? []
            _self.defaultDisplayedUsers = result?.data ?? []
            _self.tableView.reloadData()
            _self.tableView.beginUpdates()
            _self.tableView.endUpdates()
            UserDefaultsHelper.standard.usersList = result?.data ?? []
        })
    }
    
    @objc func refreshUsers() {
        UserDefaults.standard.removeObject(forKey: "users")
        loadUsers()
        self.tableView.reloadData()
    }
    
}

extension UsersListController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        displayedUsers = searchText.isEmpty ? defaultDisplayedUsers : defaultDisplayedUsers.filter {
            (user: UserShortModel) -> Bool in
            let username = user.firstName + user.lastName
            return username.range(
                of: searchText,
                options: .caseInsensitive,
                range: nil,
                locale: nil
            ) != nil
        }
        tableView.reloadData()
    }
}

class UserCell: UITableViewCell {
    
    private let profileUsernameLabel = UILabel()
    private let profilePictureView = UIImageView()
    private let profileFullnameLabel = UILabel()
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        
        defineLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePictureView.image = nil
        profileUsernameLabel.text = nil
        profileFullnameLabel.text = nil
    }
    
    private func defineLayout() {
        
        contentView.addSubview(profilePictureView)
        contentView.addSubview(profileUsernameLabel)
        contentView.addSubview(profileFullnameLabel)
        
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        profilePictureView.clipsToBounds = true
        profilePictureView.layer.cornerRadius = 30
        
        profileUsernameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileUsernameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        profileUsernameLabel.numberOfLines = 0
        profileUsernameLabel.textAlignment = .left
        profileUsernameLabel.textColor = .label

        profileFullnameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileFullnameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        profileFullnameLabel.numberOfLines = 0
        profileFullnameLabel.textAlignment = .left
        profileFullnameLabel.textColor = .secondaryLabel
        
        NSLayoutConstraint.activate([
            profilePictureView.widthAnchor.constraint(equalToConstant: 60),
            profilePictureView.heightAnchor.constraint(equalToConstant: 60),
            profilePictureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profilePictureView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            profilePictureView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
           
            profileUsernameLabel.leftAnchor.constraint(equalTo: profilePictureView.rightAnchor, constant: 10),
            profileUsernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
           
            profileFullnameLabel.leftAnchor.constraint(equalTo: profileUsernameLabel.leftAnchor),
            profileFullnameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 10),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: UITableView.automaticDimension)
        ])
    }
    
    func setUser(with data: UserShortModel) {
        self.profilePictureView.kf.indicatorType = .activity
        self.profilePictureView.kf.setImage(
            with: URL(string: data.picture),
            options: [
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ]
        )
        self.profileUsernameLabel.text = data.firstName.lowercased() + data.lastName.lowercased()
        self.profileFullnameLabel.text = data.firstName + " " + data.lastName
    }
}

