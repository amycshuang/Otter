//
//  Protocols.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/25/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import Foundation
import UIKit

protocol HomeControllerProtocol: class {
    func handleMenuToggle(for menuItem: MenuItem?)
}

protocol ZoomImageProtocol: class {
    func zoomImage(for imageView: UIImageView)
}

protocol SaveImageProtocol: class {
    func saveImageToLibrary()
    func cancelSaveImage() 
}

protocol AddPostProtocol: class {
    func presentAddPost() 
}

protocol PostActionProtocol: class {
    func postFavorited(cell: PostTableViewCell)
    func postShared(cell: PostTableViewCell)
    func presentUserProfile(cell: PostTableViewCell)
}

protocol ProfileSegmentedControlProtocol: class {
    func changeToIndex(index: Int)
}

