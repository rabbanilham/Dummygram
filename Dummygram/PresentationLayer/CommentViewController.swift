//
//  CommentViewController.swift
//  Dummygram
//
//  Created by Bagas Ilham on 17/05/22.
//

import UIKit
import Kingfisher

final class CommentViewController: UITableViewController {
    
    var API: DummyAPI?
    var feedAPI: DummyAPI?
    var postId: String?
    var displayedFeed: FeedModel?
    var displayedComments: [CommentModel]?
    var loadingIndicator = UIActivityIndicatorView()
    var comment: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add comment"
        view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeDismissKeyboard))
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
        
        
        tableView.register(CommentCell.self, forCellReuseIdentifier: "\(CommentCell.self)")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelButtonTap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(onSendCommentButtonTap))
        
        setFeed()
        setComments()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (displayedComments?.count ?? 0) + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(CommentCell.self)", for: indexPath) as? CommentCell else { return UITableViewCell() }
            cell.commentDidEndEditing = { comment in
                self.comment = comment
            }
            cell.selectionStyle = .none
            guard let displayedFeed = displayedFeed else {
                return UITableViewCell()
            }

            cell.setFeed(with: displayedFeed)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            guard let displayedComments = displayedComments else {
                return UITableViewCell()
            }
            let attrUsername = NSMutableAttributedString(
                string: (displayedComments[row - 1].owner.firstName.lowercased()) + (displayedComments[row - 1].owner.lastName.lowercased()),
                attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]
            )
            let attrComment = NSAttributedString(
                string: " \(displayedComments[row - 1].message)",
                attributes: [.font : UIFont.systemFont(ofSize: 14)]
            )
            attrUsername.append(attrComment)
            cell.textLabel?.attributedText = attrUsername
            cell.contentView.heightAnchor.constraint(equalToConstant: 25).isActive = true
            return cell
        }
    }
    
    
}

extension CommentViewController {
    
    func setFeed() {
        loadingIndicator.startAnimating()
        feedAPI?.getFeed { [weak self] result, error in
            guard let _self = self else { return }
            _self.displayedFeed = result
            _self.tableView.reloadData()
            _self.loadingIndicator.stopAnimating()
        }
    }
    
    func setComments() {
        loadingIndicator.startAnimating()
        API?.getFeedComments(postId: postId!, completionHandler: { [weak self] result, error in
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
            let alertController = UIAlertController(title: "Comment empty", message: "Please type your comment and try again.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel)
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
        guard let id = postId else { return }
        API?.addComment(comment: comment ?? "", ownerId: ownerIds.randomElement()!, postId: id)
        navigationController?.dismiss(animated: true)
    }
}

class CommentCell: UITableViewCell {
    
    typealias CommentDidEndEditing = (String) -> Void
    var commentDidEndEditing: CommentDidEndEditing?
    
    let photoView = UIImageView()
    let captionLabel = UILabel()
    let textField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        textField.backgroundColor = .secondarySystemBackground
        textField.addTarget(Any.self, action: #selector(handleCommentChange), for: .editingChanged)
        
        NSLayoutConstraint.activate([
        
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            photoView.heightAnchor.constraint(equalTo: photoView.widthAnchor, multiplier: 0.66),
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

