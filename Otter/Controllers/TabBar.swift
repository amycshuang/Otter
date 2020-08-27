//
//  TabBar.swift
//  Otter
//
//  Created by Amy Chin Siu Huang on 7/23/20.
//  Copyright © 2020 Amy Chin Siu Huang. All rights reserved.
//

import UIKit

class TabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.isTranslucent = false
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = Constants.blue
        tabBarAppearance.unselectedItemTintColor = .lightGray
        
        let tabHeight = self.tabBar.frame.height
        Constants.tabBarHeight = tabHeight
        
        let homeContainerVC = HomeMenuContainer()
        homeContainerVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "homeicon"), selectedImage: UIImage(named: "homeicon"))
        
        let globalPostsVC = UINavigationController(rootViewController: GlobalPosts())
        globalPostsVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "globalicon"), selectedImage: UIImage(named: "globalicon"))
        
        let searchUserVC = UINavigationController(rootViewController: SearchUser())
        searchUserVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "searchicon"), selectedImage: UIImage(named: "searchicon"))
        
        let messagesVC = UINavigationController(rootViewController: Messages())
        messagesVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "messageiconfilled"), selectedImage: UIImage(named: "messageiconfilled"))
        
        
        let tabBars = [homeContainerVC, globalPostsVC, searchUserVC, messagesVC]
        
        viewControllers = tabBars
        
    }

}
