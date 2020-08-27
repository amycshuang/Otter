//
//  ForgotPassword.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/12/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth

class ForgotPassword: UIViewController {
    
    var emailTextField: UITextField!
    var backButton: UIButton!
    var resetPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.blue
        self.hideKeyboardWhenViewTapped()
        self.navigationController?.navigationBar.isHidden = true
        
        emailTextField = UITextField()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTextField.textColor = .white
        emailTextField.bottomBorder()
        emailTextField.addTarget(self, action: #selector(checkEmail), for: .allEditingEvents)
        view.addSubview(emailTextField)
        
        backButton = UIButton()
        backButton.setImage(UIImage(named: "backarrow"), for: .normal)
        backButton.addTarget(self, action: #selector(popForgotPasswordVC), for: .touchUpInside)
        view.addSubview(backButton)
        
        resetPasswordButton = UIButton()
        resetPasswordButton.setTitle("Email Me A Reset Link", for: .normal)
        resetPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        resetPasswordButton.setTitleColor(Constants.darkerBlue, for: .normal)
        resetPasswordButton.backgroundColor = Constants.bluewhite
        resetPasswordButton.layer.borderColor = Constants.bluewhite.cgColor
        resetPasswordButton.layer.borderWidth = 1
        resetPasswordButton.layer.cornerRadius = 8
        resetPasswordButton.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        view.addSubview(resetPasswordButton)
        
        setUpConstraints()
    }
    
    @objc func popForgotPasswordVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func checkEmail() {
        guard let email = emailTextField.text else { return }
        if Utilities.isValidEmail(email) {
            resetPasswordButton.setTitleColor(Constants.blue, for: .normal)
            resetPasswordButton.backgroundColor = .white
            resetPasswordButton.layer.borderColor = UIColor.white.cgColor
        }
        else {
            resetPasswordButton.setTitleColor(Constants.darkerBlue, for: .normal)
            resetPasswordButton.backgroundColor = Constants.bluewhite
            resetPasswordButton.layer.borderColor = Constants.bluewhite.cgColor
        }
    }
    
    @objc func resetPassword() {
        guard let email = emailTextField.text else { return }
        if Utilities.isValidEmail(email) {
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                DispatchQueue.main.async {
                        if let error = error as NSError? {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .invalidRecipientEmail:
                            self.alert(message: "Invalid email recipient", title: "Error")
                        default:
                            self.alert(message: "There was an error in sending you a reset email. Please make sure the email is correct and try again.", title: "Error")
                        }
                    }
                    else {
                        self.alertWithAction(message: "The reset email was successfully sent. Please check your inbox", title: "Success")
                    }

                }
            }
        }
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
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(10)
            make.top.equalTo(view.snp.top).offset(60)
            make.width.height.equalTo(35)
        }
        
        resetPasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.bottom).offset(verticalPadding)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(emailTextField.snp.width)
            make.height.equalTo(45)
        }
        
    }

}
