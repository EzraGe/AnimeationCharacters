//
//  CellReusable.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/29.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

protocol CellReusable {
    static var cellReuseIdentifier : String { get }
}

protocol FavouriteCell {
    var favourBtn : FavouriteButton { get }
    var like : (_ data : FeedListModel) -> () { set get }
    var cancelFavourite : (_ data : FeedListModel) -> () { set get }
}
