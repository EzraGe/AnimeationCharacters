//
//  AD.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/5.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation

struct ADModel : FeedListModel {
    var cellType: String
    var name : String
    var description : String
    
    init(name : String, description : String) {
        self.name = name
        self.description = description
        self.cellType = "\(ADCell.self)"
    }
}
