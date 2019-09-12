//
//  Common.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/30.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

let bottomSafeAreaHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0

let hasSafeArea : Bool = (bottomSafeAreaHeight > 0)

let statusBarHeight = CGFloat(hasSafeArea ? 44 : 20)
let navigationBarHeight = CGFloat(44)

let screenSize = UIScreen.main.bounds.size
let screenWidth = screenSize.width
let screenHeight = screenSize.height
