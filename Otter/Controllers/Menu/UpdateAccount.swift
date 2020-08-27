//
//  UpdateAccount.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/12/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class UpdateAccount: UIViewController {
    
    var updateProperty: Setting!
    var updateTextField: UITextField!
    var updateButton: UIButton!
    var updateMessage: MessagePopup!
    var placeholder = ""
    var validField: Bool = false
    
    init(updateProperty: Setting) {
        super.init(nibName: nil, bundle: nil)
        self.updateProperty = updateProperty
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.bluewhite
        
        updateTextField = UITextField()
        switch updateProperty {
        case .updateEmail:
            title = "Update Email"
            placeholder = "New Email"
        case .updatePassword:
            title = "Update Password"
            placeholder = "New Password"
            updateTextField.isSecureTextEntry = true
        default:
            title = ""
        }
    
        updateTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: Constants.darkerBlue])
        updateTextField.textColor = .darkGray
        updateTextField.settingsBottomBorder()
        updateTextField.addTarget(self, action: #selector(checkField), for: .allEditingEvents)
        view.addSubview(updateTextField)
        
        updateButton = UIButton()
        updateButton.setTitle("Update", for: .normal)
        updateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        updateButton.setTitleColor(Constants.blue, for: .normal)
        updateButton.backgroundColor = Constants.bluewhite
        updateButton.layer.borderColor = Constants.blue.cgColor
        updateButton.layer.borderWidth = 1
        updateButton.layer.cornerRadius = 8
        updateButton.addTarget(self, action: #selector(updateUserProperty), for: .touchUpInside)
        view.addSubview(updateButton)
        
        setUpConstraints()
    }
    
    @objc func checkField() {
        switch updateProperty {
        case .updateEmail:
            checkEmail()
        case .updatePassword:
            checkPassword()
        default:
            print("default")
        }
    }
    
    func checkEmail() {
        guard let email = updateTextField.text else { return }
        if Utilities.isValidEmail(email) {
            updateButton.setTitleColor(.white, for: .normal)
            updateButton.backgroundColor = Constants.darkerBlue
            updateButton.layer.borderColor = Constants.darkerBlue.cgColor
            validField = true
        }
        else {
            updateButton.setTitleColor(Constants.blue, for: .normal)
            updateButton.backgroundColor = Constants.bluewhite
            updateButton.layer.borderColor = Constants.blue.cgColor
            validField = false
        }

    }
    
    func checkPassword() {
        guard let password = updateTextField.text else { return }
        if Utilities.isValidPassword(password) {
            updateButton.setTitleColor(.white, for: .normal)
            updateButton.backgroundColor = Constants.darkerBlue
            updateButton.layer.borderColor = Constants.darkerBlue.cgColor
            validField = true
        }
        else {
            updateButton.setTitleColor(Constants.blue, for: .normal)
            updateButton.backgroundColor = Constants.bluewhite
            updateButton.layer.borderColor = Constants.blue.cgColor
            validField = false
        }
    }
    
    @objc func updateUserProperty() {
        if validField == true {
            switch updateProperty {
            case .updatePassword:
                guard let password = updateTextField.text else { return }
                DatabaseManager.updatePassword(newPassword: password) { (message) in
                    self.updateMessage = MessagePopup()
                    self.updateMessage.text = message
                    self.view.addSubview(self.updateMessage)
                    self.setUpMessageConstraints()
                    Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.dismissMessagePopup), userInfo: nil, repeats: false)
                }
            case .updateEmail:
                guard let email = updateTextField.text else { return }
                DatabaseManager.updateEmail(newEmail: email) { (message) in
                    self.updateMessage = MessagePopup()
                    self.updateMessage.text = message
                    self.view.addSubview(self.updateMessage)
                    self.setUpMessageConstraints()
                    Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.dismissMessagePopup), userInfo: nil, repeats: false)
                }
            default:
                print("default")
            }
        }
    }
    
    @objc func dismissMessagePopup() {
        if updateMessage != nil {
            updateMessage.removeFromSuperview()
        }
    }
    
    func setUpMessageConstraints() {
        updateMessage.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
    }
    
    func setUpConstraints() {
        let textHeight: CGFloat = 35
        let verticalPadding: CGFloat = 20
        let width: CGFloat = 60
        
        updateTextField.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(50)
            make.width.equalTo(view.snp.width).offset(-width)
            make.height.equalTo(textHeight)
        }
        
        updateButton.snp.makeConstraints { (make) in
            make.top.equalTo(updateTextField.snp.bottom).offset(verticalPadding)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(updateTextField.snp.width)
            make.height.equalTo(45)
        }
    }
            
}
