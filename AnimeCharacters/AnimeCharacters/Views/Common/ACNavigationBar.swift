//
//  ACNavigationBar.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/1.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

enum BackButtonStyle {
    case white
    case black
    case clear
}

class ACNavigationBar : UIView {
    var backButton : UIButton = UIButton()
    var titleLabel : UILabel = UILabel()
    var backButtonHandler : () -> () = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backButton)
        self.addSubview(self.titleLabel)
        
        self.backButton.addTarget(self, action: #selector(onBackButtonClick), for: UIControl.Event.touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let square : CGFloat = 44
        let y = (self.bounds.height - square) * 0.5
        self.backButton.frame = CGRect.init(x: 10, y: y, width: square, height: square)
        
        let titleX = 10 + square + 15
        let titleW = screenWidth - 2 * titleX
        self.titleLabel.frame = CGRect.init(x: titleX, y: 0, width: titleW, height: self.bounds.height)
    }
    
    @objc func onBackButtonClick() {
        self.backButtonHandler()
    }
    
    func setBackButtonStyle(style : BackButtonStyle) {
        if style == .clear {
            self.backButton.isHidden = true
            return
        }
        
        let imgName = (style == BackButtonStyle.white ? "btn_back_w" : "btn_back_b")
        self.backButton.setImage(UIImage.init(named: imgName), for: UIControl.State.normal)
    }
}
