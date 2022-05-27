//
//  BrowseViewController.swift
//  Dummygram
//
//  Created by Bagas Ilham on 17/05/22.
//

import Foundation
import UIKit
import Kingfisher

final class CollectionViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = makeCollectionView()
    
    var collections: [[FeedModel]] = [[],[]]
    var API: DummyAPI?
    var loadingIndicator = UIActivityIndicatorView()
    
    var likedArray: [Bool]?
    
//    let touchGestureRecognizer = UIGestureRecognizer(target: (Any).self, action: #selector(showFeeds))
    
    private let screenFrame: CGRect = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        title = "Collections"
        setupAddSubview()
        setupConstraint()
        
        let refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshFeeds)
        )
        refreshButton.tintColor = .label
        navigationItem.rightBarButtonItem = refreshButton

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
        
        loadFeeds(forSection: 0)
        loadFeeds(forSection: 1)
//        print("section element count: \(collections[0].count)")
    }
    
    private func setupAddSubview() {
        view.addSubview(collectionView)
    }
    
    private func setupConstraint() {
        let builder: (UIView) -> [NSLayoutConstraint] = { view in
            let constraints: [NSLayoutConstraint] = [
                view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                view.topAnchor.constraint(equalTo: self.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ]
            return constraints
        }
        collectionView.makeConstraint(builder: builder)
    }
    
    private func makeCollectionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _) -> NSCollectionLayoutSection in
            switch sectionIndex {
            case 0:
                return self.makeFavoriteSection()
            default:
                return self.makeFavoriteSection()
            }
        }
        return layout
    }
    
    private func makeFavoriteSection() -> NSCollectionLayoutSection {
                
        let item: NSCollectionLayoutItem = {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            return item
        }()
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8),
            heightDimension: .absolute(440)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 50,
            leading: 2.5,
            bottom: 50,
            trailing: 2.5
        )
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            items.forEach { item in
                let distanceFromCenter = 0.15 * abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                let minScale: CGFloat = 0.3
                let maxScale: CGFloat = 1
                let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        
        return section
    }
    
    private func makeCollectionView() -> UICollectionView {
        let collectionLayout: UICollectionViewLayout = makeCollectionLayout()
        let view = UICollectionView(frame: screenFrame, collectionViewLayout: collectionLayout)
        view.registerCell(UICollectionViewCell.self)
        view.registerCell(CollectionViewCell.self)
        view.backgroundColor = .white
        
        view.dataSource = self
        return view
    }
    
}

extension CollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collections.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return collections[section].count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let section: Int = indexPath.section
        let row = indexPath.row
        switch section {
        case 0,1:
            let feed = (collections[section])[row]
            return dequeueCell(CollectionViewCell.self, in: collectionView, at: indexPath) { cell in
                cell.setFeed(with: feed)
                cell.layer.cornerRadius = 10
                cell.layer.shadowRadius = 2
                cell.backgroundColor = .secondarySystemBackground
                cell.onCommentTap = {
                    let vc = CommentViewController()
                    vc.postId = feed.id
                    guard let postId = cell.postId else {return}
                    vc.postId = postId
                    vc.API = DummyAPI()
                    let nc = UINavigationController()
                    nc.modalPresentationStyle = .fullScreen
                    nc.addChild(vc)
                    self.present(nc, animated: true)
                }
                cell.onAvatarTap = {
                    let user = self.collections[section][row].owner
                    let vc = UserDetailViewController()
                    vc.title = user.firstName.lowercased() + user.lastName.lowercased()
                    let userId = user.id
                    vc.userId = userId
                    vc.API = DummyAPI()
                    let nc = UINavigationController()
                    nc.addChild(vc)
                    self.navigationController?.showDetailViewController(nc, sender: Any.self)
                }
                cell.onShareTap = {
                    FeedSharer.share(in: self, feedCaption: feed.text, feedOwner: "\(feed.owner.firstName) \(feed.owner.lastName)", feedImageUrlString: feed.image)
                }
            }
            
        default:
            return dequeueCell(UICollectionViewCell.self, in: collectionView, at: indexPath) { cell in
                let item: Int = indexPath.item
                if item % 2 == 0 {
                    cell.contentView.backgroundColor = .systemGray
                } else {
                    cell.contentView.backgroundColor = .systemBlue
                }
            }
        }
    }
}

extension CollectionViewController {
    
    func loadFeeds(forSection: Int) {
        let randomPage = Int.random(in: 1...10)
        let randomLimit = Int.random(in: 20...40)
        loadingIndicator.startAnimating()
        let localCollections = UserDefaultsHelper.standard.collections
        if !localCollections.isEmpty {
            self.collections[forSection] = localCollections
            self.collectionView.reloadData()
            self.loadingIndicator.stopAnimating()
            return
        }
        
        API?.getFeeds(
            page: randomPage,
            limit: randomLimit,
            completionHandler: { [weak self] result, error in
            guard let _self = self else {return}
            _self.collections[forSection] = result?.data ?? []
            _self.collectionView.reloadData()
            UserDefaultsHelper.standard.collections = result?.data ?? []
            _self.loadingIndicator.stopAnimating()
        })
    }
    
    @objc func refreshFeeds() {
        UserDefaults.standard.removeObject(forKey: "collections")
        loadFeeds(forSection: 0)
        loadFeeds(forSection: 1)
        self.collectionView.reloadData()
    }
    
    @objc func onCellTap() {
        
    }
}

final class CollectionViewCell: UICollectionViewCell {

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
    let publishedDateLabel = UILabel()
    
    var postId: String?
    
    
    private var isLiked: Bool = false
    typealias OnLikeTapped = (Bool) -> Void
    var onLikeTap: OnLikeTapped?
    
    typealias OnCommentTapped = () -> Void
    var onCommentTap: OnCommentTapped?
    
    typealias OnAvatarTapped = () -> Void
    var onAvatarTap: OnAvatarTapped?
    
    typealias OnShareTapped = () -> Void
    var onShareTap: OnShareTapped?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        saveButton.setImage(UIImage(systemName: "flag"), for: .normal)
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
        contentView.addSubview(publishedDateLabel)
        
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
        moreButton.contentMode = .scaleAspectFill
        moreButton.tintColor = .label
        moreButton.menu = UIMenu(title: "", options: .displayInline, children: menuElements())
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFill
        
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(UIImage(systemName: "heart")?.withRenderingMode(.automatic), for: .normal)
        likeButton.tintColor = .label
        likeButton.contentMode = .scaleAspectFill
        likeButton.addTarget(Any.self, action: #selector(onLikeButtonTapped), for: .touchUpInside)
        
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.setImage(UIImage(systemName: "bubble.left")?.withRenderingMode(.automatic), for: .normal)
        commentButton.tintColor = .label
        commentButton.contentMode = .scaleAspectFill
        commentButton.addTarget(Any.self, action: #selector(onCommentButtonTapped), for: .touchUpInside)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(UIImage(systemName: "paperplane")?.withRenderingMode(.automatic), for: .normal)
        shareButton.tintColor = .label
        shareButton.contentMode = .scaleAspectFill
        shareButton.addTarget(Any.self, action: #selector(onShareButtonTapped), for: .touchUpInside)

        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setImage(UIImage(systemName: "flag")?.withRenderingMode(.automatic), for: .normal)
        saveButton.tintColor = .label
        saveButton.contentMode = .scaleAspectFill
        
        likesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        likesCountLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        captionLabel.numberOfLines = 0
        captionLabel.textAlignment = .left
        
        publishedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        publishedDateLabel.font = .systemFont(ofSize: 14)
        publishedDateLabel.textColor = .secondaryLabel
        publishedDateLabel.numberOfLines = 0
        
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
            photoView.heightAnchor.constraint(equalTo: photoView.widthAnchor, multiplier: 0.7),
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
//            captionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            publishedDateLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 10),
//            publishedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            publishedDateLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
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
        
        self.publishedDateLabel.text = dateFormatting(date: data.publishDate).uppercased()
        
        self.postId = data.id
    }
    
    func dateFormatting(date: String) -> String {
        let today = Date.now
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM yyyy"

        let intervalFormatter = DateComponentsFormatter()
        intervalFormatter.maximumUnitCount = 1
        intervalFormatter.unitsStyle = .full
        intervalFormatter.zeroFormattingBehavior = .dropAll
        intervalFormatter.allowedUnits = [.day, .hour, .minute, .second]
        
        let formattedDate = dateFormatterGet.date(from: String(date.prefix(18)))
        let intervalString = intervalFormatter.string(from: formattedDate!, to: today)
        if Int((intervalString?.prefix(3))!)! > 364 {
            return dateFormatterPrint.string(from: formattedDate!)
        } else {
            return "\(intervalString!) ago"
        }
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

extension CollectionViewCell {
    
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
    
    @objc private func onShareButtonTapped() {
        onShareTap?()
    }
    
}
