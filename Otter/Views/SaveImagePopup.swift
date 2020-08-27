//
//  SaveImagePopup.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/12/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SaveImagePopup: UIView {
    
    weak var saveImageDelegate: SaveImageProtocol?
    var saveButton: UIButton!
    var cancelButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        
        saveButton = UIButton()
        saveButton.setTitle("Save Image", for:  .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = Constants.blue
        saveButton.layer.borderColor = Constants.blue.cgColor
        saveButton.layer.borderWidth = 1
        saveButton.layer.cornerRadius = 8
        self.addSubview(saveButton)
        
        cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setTitleColor(Constants.blue, for: .normal)
        cancelButton.layer.borderColor = Constants.blue.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 8
        self.addSubview(cancelButton)
        
        setUpConstraints()
        
    }
    
    @objc func saveImage() {
        saveImageDelegate?.saveImageToLibrary()
    }
    
    @objc func cancel() {
        saveImageDelegate?.cancelSaveImage()
    }
    
    func setUpConstraints() {
        let buttonWidth: CGFloat = 170
        let buttonHeight: CGFloat = 60
        
        saveButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-40)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(40)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
