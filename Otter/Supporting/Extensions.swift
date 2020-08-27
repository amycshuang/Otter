//
//  Extensions.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/8/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UITextField {
    func bottomBorder() {
        self.layer.backgroundColor = Constants.blue.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowOpacity = 0.70
        self.layer.shadowRadius = 0.0
        self.layer.shadowColor = UIColor.white.cgColor
    }
    
    func blackBottomBorder() {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowOpacity = 0.70
        self.layer.shadowRadius = 0.0
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func grayBottomBorder() {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowOpacity = 0.70
        self.layer.shadowRadius = 0.0
        self.layer.shadowColor = UIColor.gray.cgColor
    }
    
    func settingsBottomBorder() {
        self.layer.backgroundColor = Constants.bluewhite.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowOpacity = 0.70
        self.layer.shadowRadius = 0.0
        self.layer.shadowColor = Constants.darkerBlue.cgColor
    }
}

extension UIViewController {
    
    func alert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertWithAction(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (alertAction) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenViewTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension UIImageView {
    func getImage(from url: String) {
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            self.image = cachedImage
            return
        }
        
        guard let imageUrl = URL(string: url) else { return }
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if error != nil {
                guard let errorDescription = error?.localizedDescription else { return }
                print(errorDescription)
                return
            }
            DispatchQueue.main.async {
                guard let imageData = data else { return }
                if let downloadedImage = UIImage(data: imageData) {
                    imageCache.setObject(downloadedImage, forKey: url as NSString)
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}

extension UITableView {
    func validIndexPath(indexPath: IndexPath) -> Bool {
        if indexPath.section >= self.numberOfSections || indexPath.row >= self.numberOfRows(inSection: indexPath.section){
            return false
        }
        return true 
    }
}

extension UIImage {
    
    func isOriginalImage(image: UIImage) -> Bool {
        let originalImageData = self.pngData()! as NSData
        let newImageData = image.pngData()! as NSData
        return originalImageData.isEqual(to: newImageData as Data)
    }
    
}
