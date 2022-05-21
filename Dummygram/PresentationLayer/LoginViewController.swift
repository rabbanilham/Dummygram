//
//  ViewController.swift
//  Dummygram
//
//  Created by Bagas Ilham on 13/05/22.
//

import UIKit
import LocalAuthentication

class LoginViewController: UITableViewController {
        
    private let loginImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "Instagram")?.withRenderingMode(.alwaysTemplate)
        image.contentMode = .scaleAspectFit
        image.tintColor = .label
            
            return image
        }()
    
    private let emailTextField: UITextField = {
       let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        textField.backgroundColor = .secondarySystemBackground
        textField.placeholder = "Phone number, username or email"
        textField.addTarget(Any.self, action: #selector(handleEmailTextChange), for: .editingChanged)
        textField.layer.cornerRadius = 5
    

        return textField
    }()
    
    
    private let orView: UIView = {
       let view = UIView()
        let line = UIView()
        let label = UILabel()
        
        view.addSubview(line)
        view.addSubview(label)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground

        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .systemGray5
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        line.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        line.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.text = "OR"
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.backgroundColor = .systemBackground
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        return view
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        textField.backgroundColor = .secondarySystemBackground
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.addTarget(Any.self, action: #selector(handlePasswordTextChange), for: .editingChanged)
        textField.layer.cornerRadius = 5


        return textField
    }()
    
    private let forgotButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.systemBlue, for: .normal)

        button.setTitle("Forgot Password?", for: .normal)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(Any.self, action: #selector(handleNoInputTextField), for: .touchUpInside)
        return button
    }()
    
    private let appleSignInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.backgroundColor = .label
        button.layer.cornerRadius = 10
        button.setImage(UIImage(systemName: "applelogo"), for: .normal)
        button.tintColor = .systemBackground
//        button.setTitle(" Sign In With Apple", for: .normal)
        let attributedTitle = NSMutableAttributedString(string: " Sign In With Apple")
        attributedTitle.addAttribute(.foregroundColor, value: UIColor.systemBackground, range: NSRange(location: 0, length: 19))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(Any.self, action: #selector(biometricLogin), for: .touchUpInside)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        
        cell.contentView.addSubview(loginImage)
        cell.contentView.addSubview(emailTextField)
        cell.contentView.addSubview(passwordTextField)
        cell.contentView.addSubview(forgotButton)
        cell.contentView.addSubview(loginButton)
        cell.contentView.addSubview(orView)
        cell.contentView.addSubview(appleSignInButton)
        
        NSLayoutConstraint.activate([
        
            loginImage.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor, constant: 150),
            loginImage.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            loginImage.widthAnchor.constraint(equalToConstant: 230),
            loginImage.heightAnchor.constraint(equalToConstant: 80),
            
            
            emailTextField.topAnchor.constraint(equalTo: loginImage.bottomAnchor, constant: 20),
            emailTextField.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            emailTextField.widthAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.widthAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.widthAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),

            forgotButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 5),
            forgotButton.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            forgotButton.heightAnchor.constraint(equalToConstant: 30),
            
            loginButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: forgotButton.bottomAnchor, constant: 25),
            loginButton.widthAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.widthAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            
            orView.widthAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.widthAnchor),
            orView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            orView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            orView.heightAnchor.constraint(equalToConstant: 30),

            appleSignInButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            appleSignInButton.topAnchor.constraint(equalTo: orView.bottomAnchor, constant: 20),
            appleSignInButton.widthAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.widthAnchor),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 45),
            appleSignInButton.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor, constant: 10)
           
        ])
        
        
        return cell
    }

}

extension LoginViewController {
    @objc func handleNoInputTextField() {
        guard let emailText = emailTextField.text?.trimmingCharacters(in: .whitespaces) else {
            return
        }
        
        guard let passwordText = passwordTextField.text?.trimmingCharacters(in: .whitespaces) else {
            return
        }
        
        switch(emailText.isEmpty,passwordText.isEmpty) {
        case (true,true):
            let alert = UIAlertController(title: "Try Again", message: "Please input your credentials.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        case (true, _) :
            let alert = UIAlertController(title: "Try Again", message: "Please input your email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        case (_, true) :
            let alert = UIAlertController(title: "Try Again", message: "Please input your password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        default:
            if emailText.isValid(.email, emailText) && passwordText.isValid(.password,passwordText) {
                UserDefaults.standard.set(emailText, forKey: "loggedUser")
                let home = TabBarController()
                home.selectedIndex = 0
                navigationController?.pushViewController(home, animated: true)
            } else {
                let alert = UIAlertController(title: "Try Again", message: "Email or Password is invalid. Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

    }
    
    @objc func handleEmailTextChange() {
        guard let text = emailTextField.text else {
            return
        }
        
        if text.isValidEmail {
            emailTextField.layer.borderColor = UIColor.systemGreen.cgColor
        } else if text.isEmpty {
            emailTextField.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        } else {
            emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        }
        
    }
    
    @objc func handlePasswordTextChange() {
        guard let text = passwordTextField.text else {
            return
        }
        
        if text.isValid(.password,text) {
            passwordTextField.layer.borderColor = UIColor.systemGreen.cgColor
        } else if text.isEmpty{
            passwordTextField.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        } else {
            passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        }
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func biometricLogin() {

        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Authenticate to log in."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        
                        UserDefaults.standard.set("biometric", forKey: "loggedUser")
                        let home = TabBarController()
                        home.selectedIndex = 0
                        self?.navigationController?.pushViewController(home, animated: true)
                        
                    } else {
                        
                    }
                }
            }
            
        } else {
            let alert = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }

    }

}
