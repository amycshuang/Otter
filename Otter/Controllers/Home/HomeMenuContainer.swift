//
//  HomeMenuContainer.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 8/16/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit

class HomeMenuContainer: UIViewController {

    var menuController: Menu!
    var homeController: UIViewController!
    var isShowMenu: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeVC()
        DatabaseManager.getUserInfo()
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return isShowMenu
    }
    
    func configureHomeVC() {
        let homeVC = Home(delegate: self, addPostDelegate: self)
        homeController = UINavigationController(rootViewController: homeVC)
        view.addSubview(homeController.view)
        //addChild(homeVC)
        homeController.didMove(toParent: self)
    }
    
    func configureMenuVC() {
        if menuController == nil {
            menuController = Menu(delegate: self)
            view.insertSubview(menuController.view, at: 0)
            addChild(menuController)
            menuController.didMove(toParent: self)
        }
        if menuController != nil {
            if menuController.profilePic.image == nil {
                guard let url = User.imageUrl else { return }
                menuController.profilePic.getImage(from: url)
            }
        }
    }
    
    func showMenuVC(shouldShow: Bool, menuItem: MenuItem?) {
        if shouldShow {
            // Show menu
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0,  options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.homeController.view.frame.width - 100
            }, completion: nil)
        }
        else {
            // Hide menu
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }) { (_) in
                guard let menuItem = menuItem else { return }
                self.didSelectMenuItem(menuItem: menuItem)
            }
        }
        animateStatusBar()
    }
    
    func didSelectMenuItem(menuItem: MenuItem) {
        if menuItem.menuItemName == "Profile" {
            let vc = UserProfile(barButtonHidden: false)
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            present(navVC, animated: true, completion: nil)
        }
        else if menuItem.menuItemName == "Settings" {
            let vc = Settings()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            present(navVC, animated: true, completion: nil)
        }
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0,  options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }

}

extension HomeMenuContainer: HomeControllerProtocol {
    func handleMenuToggle(for menuItem: MenuItem?) {
        if !isShowMenu {
            configureMenuVC()
        }
        isShowMenu.toggle()
        showMenuVC(shouldShow: isShowMenu, menuItem: menuItem)
    }
}

extension HomeMenuContainer: AddPostProtocol {
    func presentAddPost() {
        let vc = AddPost()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}

