//
//  ErrorController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/28.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

class ErrorController : BaseController {
    
    private var errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.ac_navigationBarHidden = false
        self.ac_navigationBarBackButtonStyle = .black
        
        let h : CGFloat = 40
        self.errorLabel.bounds = .init(x: 0, y: 0, width: self.view.width, height: h)
        self.errorLabel.center = self.view.center
        self.errorLabel.textColor = UIColor.Theme.black333333
        self.errorLabel.textAlignment = .center
        self.errorLabel.font = .PingFangSC_Regular(size: 24)
        self.errorLabel.text = "Currently No Data"
        self.view.addSubview(self.errorLabel)
    }
}
