//
//  FeedsController.swift
//  Dummygram
//
//  Created by Bagas Ilham on 09/05/22.
//

import UIKit
import Kingfisher

class FeedsController: UITableViewController {

    var API: DummyAPI?
    var feeds: [FeedModel] = []
    var loadingIndicator = UIActivityIndicatorView()
    var isLiked: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        tableView.register(FeedCell.self, forCellReuseIdentifier: "\(FeedCell.self)")
        
        let logoutButton = UIBarButtonItem(image: UIImage(systemName: "person.fill.xmark"), style: .plain, target: self, action: #selector(logOut))
        navigationItem.rightBarButtonItem = logoutButton
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.separatorStyle = .none
        
        view.addSubview(loadingIndicator)
        
        let builder: (UIView) -> [NSLayoutConstraint] = { view in

            let constraints: [NSLayoutConstraint] = [
                view.centerXAnchor.constraint(equalTo: super.view.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: super.view.centerYAnchor)
            ]
            return constraints
            
        }
        
        loadingIndicator.makeConstraint(builder: builder)
        loadingIndicator.hidesWhenStopped = true
        
        loadFeeds()
                
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(FeedCell.self)", for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        let feed = feeds[indexPath.row]
        cell.setFeed(with: feed)
        cell.onCommentTap = {
            let vc = CommentViewController()
            guard let postId = cell.postId else {return}
            vc.postId = postId
            vc.API = DummyAPI(query: "/post/\(postId)/comment")
            vc.feedAPI = DummyAPI(query: "/post/\(postId)")
            let nc = UINavigationController()
            nc.addChild(vc)
            self.navigationController?.showDetailViewController(nc, sender: Any.self)
        }
        cell.onAvatarTap = {
            let vc = UserDetailViewController()
            vc.title = self.feeds[indexPath.row].owner.firstName.lowercased() + self.feeds[indexPath.row].owner.lastName.lowercased()
            let userId = self.feeds[indexPath.row].owner.id
            vc.API = DummyAPI(query: "/user/\(userId)")
            let nc = UINavigationController()
            nc.addChild(vc)
            self.navigationController?.showDetailViewController(nc, sender: Any.self)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
}

extension FeedsController {
    
    func loadFeeds() {
        loadingIndicator.startAnimating()
        let localFeeds = UserDefaultsHelper.standard.feeds
        if !localFeeds.isEmpty {
            self.feeds = localFeeds
            self.tableView.reloadData()
            self.loadingIndicator.stopAnimating()
            return
        }
        API?.getFeeds(completionHandler: { [weak self] result, error in
            guard let _self = self else {return}
            _self.feeds = result?.data ?? []
            _self.tableView.reloadData()
            UserDefaultsHelper.standard.feeds = result?.data ?? []
            _self.loadingIndicator.stopAnimating()
        })
    }
    
    @objc func logOut() {
        UserDefaults.standard.removeObject(forKey: "loggedUser")
        UserDefaults.standard.removeObject(forKey: "feeds")
        UserDefaults.standard.removeObject(forKey: "collections")
        UserDefaults.standard.removeObject(forKey: "users")
        tabBarController?.navigationController?.popViewController(animated: true)
    }
}

class FeedCell: UITableViewCell {
        
    let avatarView = UIImageView()
    let usernameLabel = UILabel()
    let moreButton = UIButton()
    let photoView = UIImageView()
    let likeButton = UIButton()
    let commentButton = UIButton()
    let shareButton = UIButton()
    let saveButton = UIButton()
    let likesCountLabel = UILabel()
    let captionLabel = UILabel()
    
    var postId: String?
    
    private var isLiked: Bool = false
    typealias OnLikeTapped = (Bool) -> Void
    var onLikeTap: OnLikeTapped?
    
    typealias OnCommentTapped = () -> Void
    var onCommentTap: OnCommentTapped?
    
    typealias OnAvatarTapped = () -> Void
    var onAvatarTap: OnAvatarTapped?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        defineLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        usernameLabel.text = nil
        likesCountLabel.text = nil
        captionLabel.text = nil
    }
    
    func defineLayout() {
        
        contentView.addSubview(avatarView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        contentView.addSubview(photoView)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)
        contentView.addSubview(saveButton)
        contentView.addSubview(likesCountLabel)
        contentView.addSubview(captionLabel)
        
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(onAvatarImageTapped))
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 16
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(avatarTap)

        let usernameTap = UITapGestureRecognizer(target: self, action: #selector(onAvatarImageTapped))
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(usernameTap)
        
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(UIImage(systemName: "ellipsis")?.withRenderingMode(.automatic), for: .normal)
        moreButton.tintColor = .label
        moreButton.menu = UIMenu(title: "", children: menuElements())

        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFill
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(UIImage(systemName: "heart")?.withRenderingMode(.automatic), for: .normal)
        likeButton.addTarget(Any.self, action: #selector(onLikeButtonTapped), for: .touchUpInside)
        likeButton.tintColor = .label
        likeButton.contentMode = .scaleAspectFill
        likeButton.imageView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        likeButton.imageView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.setImage(UIImage(systemName: "bubble.left")?.withRenderingMode(.automatic), for: .normal)
        commentButton.tintColor = .label
        commentButton.contentMode = .scaleAspectFill
        commentButton.imageView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        commentButton.imageView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        commentButton.addTarget(Any.self, action: #selector(onCommentButtonTapped), for: .touchUpInside)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(UIImage(systemName: "paperplane")?.withRenderingMode(.automatic), for: .normal)
        shareButton.tintColor = .label
        shareButton.contentMode = .scaleAspectFill
        shareButton.imageView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        shareButton.imageView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setImage(UIImage(systemName: "flag")?.withRenderingMode(.automatic), for: .normal)
        saveButton.tintColor = .label
        saveButton.contentMode = .scaleAspectFill
        saveButton.imageView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        saveButton.imageView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        likesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        likesCountLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        captionLabel.numberOfLines = 0
        captionLabel.textAlignment = .left
        
        NSLayoutConstraint.activate([
        
            avatarView.heightAnchor.constraint(equalToConstant: 32),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            avatarView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            usernameLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            moreButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            moreButton.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            photoView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            photoView.heightAnchor.constraint(equalTo: photoView.widthAnchor),
            photoView.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 10),
            
            likeButton.topAnchor.constraint(equalTo: photoView.bottomAnchor,constant: 10),
            likeButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 25),
            likeButton.heightAnchor.constraint(equalToConstant: 25),
            
            commentButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 5),
            commentButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 25),
            commentButton.heightAnchor.constraint(equalToConstant: 25),

            shareButton.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 5),
            shareButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 25),
            shareButton.heightAnchor.constraint(equalToConstant: 25),

            saveButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            saveButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 25),
            saveButton.heightAnchor.constraint(equalToConstant: 25),
            
            likesCountLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 10),
            likesCountLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),

            captionLabel.topAnchor.constraint(equalTo: likesCountLabel.bottomAnchor, constant: 10),
            captionLabel.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            captionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: UITableView.automaticDimension)
        
        ])

    }
    
    func setFeed(with data: FeedModel) {
        
        self.avatarView.kf.setImage(with: URL(string: data.owner.picture), options: [.cacheOriginalImage, .transition(.fade(0.25))])
        self.usernameLabel.text = data.owner.firstName.lowercased() + data.owner.lastName.lowercased()
        self.photoView.kf.indicatorType = .activity
        self.photoView.kf.setImage(with: URL(string: data.image), options: [.cacheOriginalImage, .transition(.fade(0.25))])
        self.likesCountLabel.text = "\(data.likes) like"
        if data.likes > 1 {
            self.likesCountLabel.text! += "s"
        }
        
        let attrUsername = NSMutableAttributedString(string: data.owner.firstName.lowercased() + data.owner.lastName.lowercased(), attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .semibold)])
        let attrCaption = NSAttributedString(string: " \(data.text)")
        attrUsername.append(attrCaption)
        
        self.captionLabel.attributedText = attrUsername
        
        self.postId = data.id

    }
    
    func menuElements() -> [UIMenuElement] {
        
        var menus: [UIMenuElement] = []
        
        let unfollowFeedOwner = UIAction(title: "Suggest Less", image: UIImage(systemName: "hand.thumbsdown"), identifier: nil) { _ in
            
        }
        let hideFeed = UIAction(title: "Suggest More", image: UIImage(systemName: "hand.thumbsup"), identifier: nil) { _ in
            
        }
        let reportFeed = UIAction(title: "Save Story", image: UIImage(systemName: "square.and.arrow.down"), identifier: nil) { _ in
            
        }
        let copyFeedLink = UIAction(title: "Link", image: UIImage(systemName: "link"), identifier: nil) { _ in
            
        }
        let shareFeed = UIAction(title: "Share Story", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { _ in
        
        }
        
        menus.append(unfollowFeedOwner)
        menus.append(hideFeed)
        menus.append(reportFeed)
        menus.append(copyFeedLink)
        menus.append(shareFeed)
        
        return menus
    }
    
}

extension FeedsController {
    @objc func didTapAvatarImage(_ sender: UITapGestureRecognizer) {
        
    }
}


extension FeedCell {
    
    @objc private func onLikeButtonTapped() {
        
        isLiked.toggle()
        
        if isLiked {
            likeButton.setImage(UIImage(systemName: "heart.fill")?.withRenderingMode(.automatic), for: .normal)
            likeButton.tintColor = .systemRed
        } else {
            likeButton.setImage(UIImage(systemName: "heart")?.withRenderingMode(.automatic), for: .normal)
            likeButton.tintColor = .label
        }
        onLikeTap?(isLiked)
    }
    
    @objc private func onCommentButtonTapped() {
        onCommentTap?()
    }
    
    @objc private func onAvatarImageTapped() {
        onAvatarTap?()
        print("touched")
    }
    
}
