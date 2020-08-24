//
//  DateHeaderLabel.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/3/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class DateHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hue: 0.5417, saturation: 0.25, brightness: 0.83, alpha: 1.0)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.textColor = .white
        self.textAlignment = .center
    }
    
    func setDateString(section: Int, dateKeys: [Date]) {
        let date = dateKeys[section]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: date)
        self.text = dateString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        return CGSize(width: originalContentSize.width + 10, height: originalContentSize.height + 6)
    }
}
