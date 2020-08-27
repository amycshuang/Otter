//
//  SettingsTableViewCell.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/26/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class SettingsTableViewCell: UITableViewCell {
    
    var settingsLabel: UILabel!
    var arrowIcon: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        settingsLabel = UILabel()
        settingsLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        contentView.addSubview(settingsLabel)
        
        arrowIcon = UIImageView()
        arrowIcon.contentMode = .scaleAspectFit
        arrowIcon.image = UIImage(named: "nextarrow")
        contentView.addSubview(arrowIcon)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        let iconSize: CGFloat = 28
        let labelHeight: CGFloat = 16
        
        settingsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView.snp.left).offset(15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(labelHeight)
        }
        arrowIcon.snp.makeConstraints { (make) in
            make.trailing.equalTo(contentView.snp.trailing).offset(-15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.height.equalTo(iconSize)
        }
        
        
    }
    
    func configure(settingsOption: Setting) {
        switch settingsOption {
        case .updatePassword:
            settingsLabel.text = "Update Password"
        case .updateEmail:
            settingsLabel.text = "Update Email"
        case .deleteAccount:
            settingsLabel.text = "Delete Account"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
