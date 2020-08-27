//
//  Utilities.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/7/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit

struct Utilities {
    
    /// Valid password are at least 8 characters long and have at least 1 letter and 1 special character
    static func isValidPassword(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    
    static func stripTimeOffDate(from originalDate: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: originalDate)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
}
