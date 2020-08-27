//
//  MessagePopup.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/12/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit

class MessagePopup: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.alpha = 0.7
        self.textAlignment = .center
        self.textColor = .white
        self.backgroundColor = .black
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
