//
//  ViewController.swift
//  Challenge5
//
//  Created by Bagas Ilham on 28/04/22.
//

import UIKit
import Kingfisher

class UserDetailViewController: UITableViewController {
    
    var API: DummyAPI?
    var displayedUser: UserModel?
    var loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadingIndicator)
        
        let builder: (UIView) -> [NSLayoutConstraint] = { view in

            let constraints: [NSLayoutConstraint] = [
                view.centerXAnchor.constraint(equalTo: super.view.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: super.view.centerYAnchor, constant: -60)
            ]
            return constraints
            
        }
        
        loadingIndicator.makeConstraint(builder: builder)
        loadingIndicator.hidesWhenStopped = true
        
        tableView.separatorStyle = .none
        tableView.register(UserDetailCell.self, forCellReuseIdentifier: "\(UserDetailCell.self)")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneBarButtonTap))
        navigationItem.rightBarButtonItem = cancelBarButton

        loadUser()

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(UserDetailCell.self)", for: indexPath) as? UserDetailCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.backgroundColor = .systemBackground
        
        guard let user = displayedUser else {return UITableViewCell()}
        cell.setUser(with: user)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


}

extension UserDetailViewController {
    
    func loadUser() {
        
        loadingIndicator.startAnimating()
        
        API?.getUserDetail(completionHandler: {[weak self] result, error in
            guard let self = self else {return}
            self.loadingIndicator.stopAnimating()
            self.displayedUser = result
//            self.title = (result?.firstName.lowercased() ?? "") + (result?.lastName.lowercased() ?? "")
            self.tableView.reloadData()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        })
        
    }
    
    @objc private func onDoneBarButtonTap() {
        navigationController?.dismiss(animated: true)
    }
        
}

final class UserDetailCell: UITableViewCell {
    
    var profileUsernameView = UILabel()
    var profilePictureView = UIImageView()
    var genderView = UILabel()
    var emailView = UILabel()
    var dateOfBirthView = UILabel()
    var phoneView = UILabel()
    var locationView = UILabel()
    var registeredDateView = UILabel()
    var updatedDateView = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        defineLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func defineLayout() {
        
        contentView.addSubview(profileUsernameView)
        contentView.addSubview(profilePictureView)
        contentView.addSubview(emailView)
        contentView.addSubview(phoneView)
        contentView.addSubview(locationView)
        contentView.addSubview(registeredDateView)
        
        profileUsernameView.translatesAutoresizingMaskIntoConstraints = false
        profileUsernameView.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        profileUsernameView.numberOfLines = 0
        profileUsernameView.textAlignment = .left
        
        profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        profilePictureView.clipsToBounds = true
        profilePictureView.layer.cornerRadius = 45
        
    //        genderView.translatesAutoresizingMaskIntoConstraints = false
        
        emailView.translatesAutoresizingMaskIntoConstraints = false
        
    //        dateOfBirthView.translatesAutoresizingMaskIntoConstraints = false
        
        phoneView.translatesAutoresizingMaskIntoConstraints = false
        
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.numberOfLines = 0
        locationView.textAlignment = .left
        
        registeredDateView.translatesAutoresizingMaskIntoConstraints = false
        
    //        updatedDateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([

            profilePictureView.widthAnchor.constraint(equalToConstant: 90),
            profilePictureView.heightAnchor.constraint(equalToConstant: 90),
            profilePictureView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 5),
            profilePictureView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            profileUsernameView.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 10),
            profileUsernameView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            locationView.topAnchor.constraint(equalTo: profileUsernameView.bottomAnchor, constant: 2),
            locationView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            phoneView.topAnchor.constraint(equalTo: locationView.bottomAnchor, constant: 2),
            phoneView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            emailView.topAnchor.constraint(equalTo: phoneView.bottomAnchor, constant: 2),
            emailView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),

            registeredDateView.topAnchor.constraint(equalTo: emailView.bottomAnchor, constant: 2),
            registeredDateView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 350)

        ])
    }
    
    func setUser(with data: UserModel) {
        
        self.profilePictureView.kf.setImage(with: URL(string: data.picture), options: [.cacheOriginalImage, .transition(.fade(1))])
        self.profileUsernameView.text = data.firstName + " " + data.lastName
        self.genderView.text = data.gender
        self.emailView.text = "✉️ " + data.email
        self.dateOfBirthView.text = data.dateOfBirth
        self.phoneView.text = "📱 " + data.phone
        self.locationView.text = "📍 " + data.location.city + ", " + data.location.country
        self.registeredDateView.text = "Joined since \((data.registerDate).prefix(10))"
        self.updatedDateView.text = "Last updated \(data.updatedDate)"

    }
}

