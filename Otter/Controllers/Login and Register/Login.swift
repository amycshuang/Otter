//
//  Login.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 6/20/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth

class Login: UIViewController {

    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var backButton: UIButton!
    var loginButton: UIButton!
    var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.blue
        self.hideKeyboardWhenViewTapped()
        self.navigationController?.navigationBar.isHidden = true
        
        emailTextField = UITextField()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTextField.textColor = .white
        emailTextField.bottomBorder()
        view.addSubview(emailTextField)
        
        passwordTextField = UITextField()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordTextField.textColor = .white
        passwordTextField.isSecureTextEntry = true
        passwordTextField.bottomBorder() 
        view.addSubview(passwordTextField)
        
        backButton = UIButton()
        backButton.setImage(UIImage(named: "backarrow"), for: .normal)
        backButton.addTarget(self, action: #selector(popLoginVC), for: .touchUpInside)
        view.addSubview(backButton)
        
        forgotPasswordButton = UIButton()
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        forgotPasswordButton.setTitleColor(Constants.bluewhite, for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        view.addSubview(forgotPasswordButton)
        
        Auth.auth().languageCode = "en"
        
        loginButton = UIButton()
        loginButton.setTitle("Log In", for:  .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        loginButton.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        loginButton.setTitleColor(Constants.blue, for: .normal)
        loginButton.backgroundColor = .white
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 8
        view.addSubview(loginButton)
        
        setUpConstraints()
    }
    
    @objc func popLoginVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func forgotPassword() {
        let vc = ForgotPassword()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func logIn() {
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if validateFields(email: email, password: password) {
                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                    if let error = error as NSError? {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .wrongPassword:
                            self.alert(message: "Incorrect email or password", title: "Error")
                        case .invalidEmail:
                            self.alert(message: "Incorrect email or password", title: "Error")
                        default:
                            self.alert(message: "There was an error logging into your account. Please try again.", title: "Error")
                        }
                    }
                    else {
                        self.transitionToMessages()
                    }
                }
            }
        }
    }
    
    func transitionToMessages() {
        DispatchQueue.main.async {
            self.view.window?.rootViewController = TabBar()
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    func validateFields(email: String, password: String) -> Bool {
        if email == "" || password == "" {
            alert(message: "Please fill out all fields", title: "Login Error")
            return false
        }
        else if !Utilities.isValidEmail(email) {
            alert(message: "Please enter a valid email", title: "Invalid Email")
            return false
        }
        return true
    }
    
    func setUpConstraints() {
        
        let textHeight: CGFloat = 35
        let verticalPadding: CGFloat = 20
        let width: CGFloat = 60
        
        emailTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(150)
            make.width.equalTo(view.snp.width).offset(-width)
            make.height.equalTo(textHeight)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(emailTextField.snp.bottom).offset(verticalPadding)
            make.width.equalTo(view.snp.width).offset(-width)
            make.height.equalTo(textHeight)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(10)
            make.top.equalTo(view.snp.top).offset(60)
            make.width.height.equalTo(35)
        }
        
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(passwordTextField.snp.bottom).offset(8)
            make.width.equalTo(140)
            make.height.equalTo(20)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom).offset(2.5*verticalPadding)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(passwordTextField.snp.width)
            make.height.equalTo(45)
        }
    }


}
