//
//  CommentViewController.swift
//  Dummygram
//
//  Created by Bagas Ilham on 17/05/22.
//

import UIKit
import Kingfisher
import IQKeyboardManagerSwift

final class CommentViewController: UITableViewController {
    
    var API: DummyAPI?
    var postId: String?
    var displayedFeed: FeedModel?
    var displayedComments: [CommentModel]?
    var loadingIndicator = UIActivityIndicatorView()
    var comment: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add comment"
        view.backgroundColor = .systemBackground
        
        IQKeyboardManager.shared.enable = true
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        let swipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(swipeDismissKeyboard)
        )
        swipe.direction = .down
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipe)
        swipe.require(toFail: tap)
        
        view.addSubview(loadingIndicator)
        
        let builder: (UIView) -> [NSLayoutConstraint] = { load in

            let constraints: [NSLayoutConstraint] = [
                load.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                load.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ]
            return constraints
            
        }
        
        loadingIndicator.makeConstraint(builder: builder)
        
        
        tableView.register(
            FeedAndTextFieldCell.self,
            forCellReuseIdentifier: "\(FeedAndTextFieldCell.self)"
        )
        tableView.register(
            CommentCell.self,
            forCellReuseIdentifier: "\(CommentCell.self)"
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.beginUpdates()
        tableView.endUpdates()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(onCancelButtonTap)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Send",
            style: .done,
            target: self,
            action: #selector(onSendCommentButtonTap)
        )
        
        setFeed()
        setComments()

    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return (displayedComments?.count ?? 0) + 1
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "\(FeedAndTextFieldCell.self)",
                for: indexPath
            ) as? FeedAndTextFieldCell else { return UITableViewCell() }
            cell.commentDidEndEditing = { comment in
//                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                self.comment = comment
            }
            cell.selectionStyle = .none
            guard let displayedFeed = displayedFeed else {
                return UITableViewCell()
            }

            cell.setFeed(with: displayedFeed)
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "\(CommentCell.self)",
                for: indexPath
            ) as? CommentCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            guard let displayedComments = displayedComments else {
                return UITableViewCell()
            }
            cell.fill(with: displayedComments[row - 1])
            
            cell.onAvatarTap = {
                let userId = displayedComments[indexPath.row - 1].owner.id
                let vc = UserDetailViewController()
                vc.userId = userId
                vc.title = displayedComments[indexPath.row - 1].owner.firstName.lowercased() + displayedComments[indexPath.row - 1].owner.lastName.lowercased()
                vc.API = DummyAPI()
                let nc = UINavigationController()
                nc.addChild(vc)
                self.navigationController?.showDetailViewController(nc, sender: Any.self)
            }
            return cell
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let row = indexPath.row
        
        switch row {
        case 0:
            return nil
        default:
            let row = indexPath.row - 1
            guard let displayedComments = displayedComments else { return nil }
            guard let API = API else { return nil }

            let comment = displayedComments[row]

            let item = UIContextualAction(
                style: .destructive,
                title: "Delete"
            ) {  (contextualAction, view, boolValue) in
                let ac = UIAlertController(
                    title: "Say goodbye to this comment",
                    message: "Are you sure want to delete this comment? This action cannot be undone.",
                    preferredStyle: .alert
                )
                let delete = UIAlertAction(
                    title: "Delete",
                    style: .destructive
                ) { _ in
                    API.deleteComment(commentId: comment.id)
                    self.displayedComments?.remove(at: row)
                    self.tableView.deleteRows(
                        at: [indexPath],
                        with: .automatic
                    )
                    boolValue(true)
//                    self.tableView.reloadData()
                }
                let cancel = UIAlertAction(
                    title: "Cancel",
                    style: .cancel
                ) { _ in
                    boolValue(true)
                }
                ac.addAction(cancel)
                ac.addAction(delete)
                self.present(ac, animated: true)
                }

            let swipeActions = UISwipeActionsConfiguration(actions: [item])

            return swipeActions
        }
    }
    
}

extension CommentViewController {
    
    func setFeed() {
        loadingIndicator.startAnimating()
        API?.getFeed(feedId: postId!) { [weak self] result, error in
            guard let _self = self else { return }
            _self.displayedFeed = result
            _self.tableView.reloadData()
        }
        loadingIndicator.stopAnimating()
    }
    
    func setComments() {
        loadingIndicator.startAnimating()
        API?.getFeedComments(
            postId: postId!,
            completionHandler: { [weak self] result, error in
            guard let _self = self else { return }
            _self.displayedComments = result?.data
            _self.tableView.reloadData()
            _self.loadingIndicator.stopAnimating()
        })
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func swipeDismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func onCancelButtonTap() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func onSendCommentButtonTap() {
        guard comment != nil
        && comment != ""
        else {
            let alertController = UIAlertController(
                title: "Comment empty",
                message: "Please type your comment and try again.",
                preferredStyle: .alert
            )
            let ok = UIAlertAction(
                title: "OK",
                style: .cancel
            )
            alertController.addAction(ok)
            present(alertController, animated: true)
            return
        }
        let ownerIds: [String] = [
            "60d0fe4f5311236168a109e8",
            "60d0fe4f5311236168a10a1a",
            "60d0fe4f5311236168a109d0",
            "60d0fe4f5311236168a10a04",
            "60d0fe4f5311236168a109cf",
            "60d0fe4f5311236168a10a22"
        ]
//        guard let id = postId else { return }
        API?.addComment(comment: comment ?? "", ownerId: ownerIds.randomElement()!, postId: postId!)
        navigationController?.dismiss(animated: true)
    }
    
}

final class FeedAndTextFieldCell: UITableViewCell {
    
    typealias CommentDidEndEditing = (String) -> Void
    var commentDidEndEditing: CommentDidEndEditing?
    
    typealias OnAvatarTapped = () -> Void
    var onAvatarTap: OnAvatarTapped?
    
    let photoView = UIImageView()
    let captionLabel = UILabel()
    let textField = UITextField()
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func defineLayout() {
        contentView.addSubview(photoView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(textField)
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.numberOfLines = 0
        captionLabel.textColor = .label
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        textField.placeholder = "Add your comment..."
        textField.backgroundColor = .systemBackground
        textField.clearButtonMode = .whileEditing
        textField.addTarget(
            Any.self,
            action: #selector(handleCommentChange),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
        
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            photoView.heightAnchor.constraint(equalTo: photoView.widthAnchor, multiplier: 1),
            photoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            captionLabel.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 15),
            captionLabel.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            captionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 15),
            textField.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            textField.heightAnchor.constraint(equalToConstant: 35),
            textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: UITableView.automaticDimension)
        
        ])
    }
    
    func setFeed(with feed: FeedModel) {
        self.photoView.kf.setImage(with: URL(string: feed.image), options: [.transition(.fade(0.2))])
        self.photoView.kf.indicatorType = .activity
        
        let attrUsername = NSMutableAttributedString(string: feed.owner.firstName.lowercased() + feed.owner.lastName.lowercased(), attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .semibold)])
        let attrCaption = NSAttributedString(string: " \(feed.text)", attributes: [.font : UIFont.systemFont(ofSize: 14)])
        attrUsername.append(attrCaption)
        self.captionLabel.attributedText = attrUsername
    }
    
    @objc func handleCommentChange() {
        commentDidEndEditing?(textField.text ?? "")
    }
    
}

final class CommentCell: UITableViewCell {

    let avatarImageView = UIImageView()
    let usernameAndCommentLabel = UILabel()
    
    typealias OnAvatarTapped = () -> Void
    var onAvatarTap: OnAvatarTapped?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        defineLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func defineLayout() {
        
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(onAvatarImageTapped))
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.addGestureRecognizer(avatarTap)

        let usernameTap = UITapGestureRecognizer(target: self, action: #selector(onAvatarImageTapped))
        usernameAndCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameAndCommentLabel.numberOfLines = 0
        usernameAndCommentLabel.addGestureRecognizer(usernameTap)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameAndCommentLabel)
        
        NSLayoutConstraint.activate([
        
            avatarImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            
            usernameAndCommentLabel.topAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: -10),
            usernameAndCommentLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            usernameAndCommentLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            usernameAndCommentLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            contentView.layoutMarginsGuide.bottomAnchor.constraint(greaterThanOrEqualTo: avatarImageView.bottomAnchor),
//            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        
        ])

    }
    
    func fill(with comment: CommentModel) {
        avatarImageView.kf.setImage(with: URL(string: comment.owner.picture))
        
        let attrUsername = NSMutableAttributedString(
            string: "\(comment.owner.firstName.lowercased())\(comment.owner.lastName.lowercased())",
            attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]
        )
        let attrComment = NSAttributedString(
            string: " \(comment.message)",
            attributes: [.font : UIFont.systemFont(ofSize: 14)]
        )
        attrUsername.append(attrComment)
        usernameAndCommentLabel.attributedText = attrUsername
    }
    
    @objc func onAvatarImageTapped() {
        onAvatarTap?()
    }

}


