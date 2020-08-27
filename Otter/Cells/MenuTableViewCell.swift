//
//  MenuTableViewCell.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/25/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit
import SnapKit

class MenuTableViewCell: UITableViewCell {

    var iconImageView: UIImageView!
    var menuItemLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
        
        menuItemLabel = UILabel()
        menuItemLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        contentView.addSubview(menuItemLabel)
        
        setUpConstraints()
        
    }
    
    func setUpConstraints() {
        let iconSize: CGFloat = 28
        let labelHeight: CGFloat = 16
        
        iconImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.height.equalTo(iconSize)
        }
        
        menuItemLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconImageView.snp.centerY)
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.height.equalTo(labelHeight)
        }
    
    }
    
    func configure(for menuItem: MenuItem) {
        iconImageView.image = UIImage(named: menuItem.menuItemIcon)
        menuItemLabel.text = menuItem.menuItemName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
