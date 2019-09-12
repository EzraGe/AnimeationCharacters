//
//  FavouriteButton.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/20.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

var favouriteBtnSquare : CGFloat = 49

class FavouriteButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage.init(named: "btn_favourite"), for: .normal)
        self.setImage(UIImage.init(named: "btn_favourite_done"), for: .selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
