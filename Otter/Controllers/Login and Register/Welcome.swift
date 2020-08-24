//
//  Welcome.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 6/24/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class Welcome: UIViewController {

    var welcomeLabel: UILabel!
    var loginButton: UIButton!
    var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.blue
        self.navigationController?.navigationBar.isHidden = true
        
        welcomeLabel = UILabel()
        welcomeLabel.text = "Otter"
        welcomeLabel.numberOfLines = 0
        welcomeLabel.textColor = .white
        welcomeLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        view.addSubview(welcomeLabel)
        
        loginButton = UIButton()
        loginButton.setTitle("Log In", for:  .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        loginButton.addTarget(self, action: #selector(pushLoginVC), for: .touchUpInside)
        loginButton.setTitleColor(Constants.blue, for: .normal)
        loginButton.backgroundColor = .white
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 8
        view.addSubview(loginButton)
        
        registerButton = UIButton()
        registerButton.setTitle("Sign Up", for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        registerButton.addTarget(self, action: #selector(pushRegisterVC), for: .touchUpInside)
        registerButton.layer.borderColor = UIColor.white.cgColor
        registerButton.layer.borderWidth = 1
        registerButton.layer.cornerRadius = 8
        view.addSubview(registerButton)
        
        setUpConstraints()
        
    }
    
    @objc func pushLoginVC() {
        let vc = Login()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func pushRegisterVC() {
        let vc = Register()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setUpConstraints() {
        let buttonWidth: CGFloat = 250
        let buttonHeight: CGFloat = 45
        welcomeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(220)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(230)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
    }

}
