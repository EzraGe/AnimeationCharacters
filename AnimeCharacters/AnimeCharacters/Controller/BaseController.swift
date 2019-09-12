//
//  BaseController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/1.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import MediaPlayer

class BaseController : UIViewController {
    open var ac_navigationBarHidden : Bool = false {
        willSet {
            self.ac_navigationBar.isHidden = newValue
        }
    }
    var ac_navigationBar = ACNavigationBar()
    
    open var ac_navigationBarBackButtonStyle : BackButtonStyle = .white {
        willSet {
            self.ac_navigationBar.setBackButtonStyle(style: newValue)
        }
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        self.ac_navigationBar.frame = CGRect.init(x: 0, y: statusBarHeight, width: screenWidth, height: navigationBarHeight)
        self.view.addSubview(ac_navigationBar)
        
        self.ac_navigationBar.titleLabel.textColor = UIColor.Theme.black333333
        self.ac_navigationBar.titleLabel.textAlignment = NSTextAlignment.center
        self.ac_navigationBar.titleLabel.font = UIFont.PingFangSC_Regular(size: 17)
        
        self.ac_navigationBarHidden = true
        
        weak var weakSelf = self
        self.ac_navigationBar.backButtonHandler = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
}


