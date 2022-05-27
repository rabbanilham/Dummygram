//
//  CreatePostViewController.swift
//  Dummygram
//
//  Created by Bagas Ilham on 19/05/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import YPImagePicker

final class CreatePostViewController: UITableViewController {
    
    var postImageUrl: URL?
    var postCaption: String?
    var ratio: CGFloat?
    let postImageView: UIImageView = UIImageView()
    let addLabel = UILabel()
    let addButton = UIButton(configuration: .filled())
    let removeButton = UIButton(configuration: .borderedTinted())
    let captionTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create a post"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(onCancelButtonTap)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Send",
            style: .plain,
            target: self,
            action: #selector(onSendButtonTap)
        )
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        setupTapWillDismissKeyboard()
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let row = indexPath.row
        switch row {
            //MARK: image cell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            
            postImageView.translatesAutoresizingMaskIntoConstraints = false
            postImageView.contentMode = .scaleAspectFill
            postImageView.backgroundColor = .secondarySystemBackground
            postImageView.clipsToBounds = true
            
            addLabel.translatesAutoresizingMaskIntoConstraints = false
            addLabel.text = "Add an image by pressing the + button below."
            addLabel.font = .systemFont(ofSize: 14)
            
            let view = cell.contentView
            view.addSubview(postImageView)
            view.addSubview(addLabel)
            
            if postImageView.image != nil {
                view.sendSubviewToBack(addLabel)
            }

            NSLayoutConstraint.activate([
                postImageView.topAnchor.constraint(equalTo:view.topAnchor),
                postImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
                postImageView.heightAnchor.constraint(equalToConstant: view.frame.width * (self.ratio ?? 0)),
                postImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                postImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                postImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                addLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                addLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            return cell
            // MARK: button cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            
            cell.contentView.addSubview(addButton)
            cell.contentView.addSubview(removeButton)
            
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.tintColor = .systemBlue
            addButton.setImage(
                UIImage(systemName: "plus"),
                for: .normal
            )
            addButton.setTitle(
                " Add an image",
                for: .normal
            )
            addButton.addTarget(
                self,
                action: #selector(onAddButtonTap),
                for: .touchUpInside
            )
            
            removeButton.translatesAutoresizingMaskIntoConstraints = false
            removeButton.tintColor = .systemRed
            removeButton.setImage(
                UIImage(systemName: "xmark"),
                for: .normal
            )
            removeButton.setTitle(
                " Remove image",
                for: .normal
            )
            removeButton.addTarget(
                self,
                action: #selector(onRemoveImageTap),
                for: .touchUpInside
            )
            
            if postImageView.image != nil {
                addButton.isEnabled = false
                removeButton.isEnabled = true
            } else {
                addButton.isEnabled = true
                removeButton.isEnabled = false
            }
            
            let layout = cell.contentView.layoutMarginsGuide
            
            NSLayoutConstraint.activate([
                removeButton.leadingAnchor.constraint(equalTo: layout.leadingAnchor),
                removeButton.trailingAnchor.constraint(equalTo: layout.centerXAnchor, constant: -10),
                removeButton.centerYAnchor.constraint(equalTo: layout.centerYAnchor),
                removeButton.heightAnchor.constraint(equalToConstant: 40),
                removeButton.topAnchor.constraint(equalTo: layout.topAnchor),
                removeButton.bottomAnchor.constraint(equalTo: layout.bottomAnchor),
                
                addButton.leadingAnchor.constraint(equalTo: layout.centerXAnchor, constant: 10),
                addButton.trailingAnchor.constraint(equalTo: layout.trailingAnchor),
                addButton.centerYAnchor.constraint(equalTo: layout.centerYAnchor),
                addButton.heightAnchor.constraint(equalToConstant: 40),
            ])
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.contentView.addSubview(captionTextField)
            captionTextField.translatesAutoresizingMaskIntoConstraints = false
            captionTextField.borderStyle = .roundedRect
            captionTextField.placeholder = "Add your caption"
            captionTextField.addTarget(
                Any.self,
                action: #selector(handleCaptionTextFieldChange),
                for: .editingChanged
            )
            let layout = cell.contentView.layoutMarginsGuide
            NSLayoutConstraint.activate([
                captionTextField.topAnchor.constraint(equalTo: layout.topAnchor),
                captionTextField.bottomAnchor.constraint(equalTo: layout.bottomAnchor),
                captionTextField.trailingAnchor.constraint(equalTo: layout.trailingAnchor),
                captionTextField.leadingAnchor.constraint(equalTo: layout.leadingAnchor),
                captionTextField.heightAnchor.constraint(equalToConstant: 50),
                captionTextField.centerXAnchor.constraint(equalTo: layout.centerXAnchor),
                captionTextField.centerYAnchor.constraint(equalTo: layout.centerYAnchor)
            ])
            return cell
        default:
            return UITableViewCell()
            
        }

    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 3
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}

extension CreatePostViewController {
    func setupTapWillDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

extension CreatePostViewController {
    @objc func onCancelButtonTap() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func onAddButtonTap() {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 10
        let imagePickerController = YPImagePicker()
        imagePickerController.didFinishPicking { [unowned imagePickerController] items, _ in
            if let photo = items.singlePhoto {
                self.ratio = (photo.image.size.height ) / (photo.image.size.width)
                self.postImageView.image = photo.image
                self.postImageUrl = photo.url
                self.tableView.reloadData()
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            imagePickerController.dismiss(animated: true)
        }
        self.present(imagePickerController, animated: true)
    }
    
    @objc func onRemoveImageTap() {
        postImageView.image = nil
        ratio = nil
        tableView.reloadData()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @objc func handleCaptionTextFieldChange() {
        guard let caption = captionTextField.text else { return }
        self.postCaption = caption
    }
    
    @objc func onSendButtonTap() {
        guard let caption = postCaption else { return }
        let ownerIds: [String] = [
            "60d0fe4f5311236168a109e8",
            "60d0fe4f5311236168a10a1a",
            "60d0fe4f5311236168a109d0",
            "60d0fe4f5311236168a10a04",
            "60d0fe4f5311236168a109cf",
            "60d0fe4f5311236168a10a22"
        ]
        
        let API = DummyAPI()
        API.addFeed(
            text: caption,
            image: ownerIds.randomElement()!,
            likes: nil,
            tags: nil,
            owner: ownerIds.randomElement()!
        )
        self.dismiss(animated: true)
    }
    
    @objc func dismissKeyboard() {
        tableView.endEditing(true)
    }
}
