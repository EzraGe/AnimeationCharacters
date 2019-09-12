//
//  HomeController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/29.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

class ACHomeTabbarController: UITabBarController, AnimeTabBarDelegate {
    
    var animeTabBar : AnimeTabBar = AnimeTabBar()
    var tabModels : Array<TabBarItem> = []
    
    func initTabs() {
        var tabModels = Array<TabBarItem>()
        
        let feedTab = TabBarItem()
        feedTab.updateName(language: .English, tabIndex: 0)
        feedTab.tabImageName = "geass"
        
        let favoTab = TabBarItem()
        favoTab.updateName(language: .English, tabIndex: 1)
        favoTab.tabImageName = "zero"
        
        tabModels.append(feedTab)
        tabModels.append(favoTab)
        
        self.tabModels = tabModels
    }
    
    override func viewDidLoad() {
        self.tabBar.barTintColor = UIColor.white
        self.initTabs()
        
        let numberOfItems = self.tabBar.items!.count
        for i in 0..<numberOfItems {
            let item : UITabBarItem = self.tabBar.items![i]
            item.isEnabled = false
        }
        
        self.animeTabBar.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: bottomSafeAreaHeight + 49)
        self.animeTabBar.tabBarItems = self.tabModels
        self.tabBar.addSubview(self.animeTabBar)
        self.animeTabBar.animeTabBarDelegate = self
        self.animeTabBar.select(at: 0)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for subview : UIView in self.tabBar.subviews {
            if type(of: subview) == NSClassFromString("UITabBarButton") ||
               type(of: subview) == NSClassFromString("_UIBarBackground") {
                subview.isHidden = true
            }
        }
    }
    
    // MARK: AnimeTabBarDelegate
    func tabBar(_ tabBar: AnimeTabBar, didSelect item: TabBarItem, at index: Int) {
        self.selectedIndex = index
    }
}

class ACNavigationController: UINavigationController {
    override func viewDidLoad() {
        self.hidesBottomBarWhenPushed = true
    }
}
