//
//  SaveImageAlert.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/12/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SaveImageAlert: UIView {
    
    weak var saveImageDelegate: SaveImageProtocol?
    var saveButton: UIButton!
    var cancelButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        
        saveButton = UIButton()
        saveButton.setTitle("Log In", for:  .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        saveButton.setTitleColor(Constants.blue, for: .normal)
        saveButton.backgroundColor = .white
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.borderWidth = 1
        saveButton.layer.cornerRadius = 8
        self.addSubview(saveButton)
        
        cancelButton = UIButton()
        cancelButton.setTitle("Sign Up", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 8
        self.addSubview(cancelButton)
        
        setUpConstraints()
        
    }
    
    @objc func saveImage() {
        saveImageDelegate?.saveImage()
    }
    
    @objc func cancel() {
        saveImageDelegate?.cancelSaveImage()
    }
    
    func setUpConstraints() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
