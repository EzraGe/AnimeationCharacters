//
//  AnimeStory.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/30.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation


struct AnimeStory : FeedListModel, CollectionModel, Equatable, Codable {
    
    var collectionType: CollectionType
    
    var cellType: String
    
    var id : Int
    var name : String
    var onlineTime : String
    var backImageURL : String
    
    init(id : Int, name : String, onlineTime : String, backImageURL : String) {
        self.id = id
        self.name = name
        self.onlineTime = onlineTime
        self.backImageURL = backImageURL
        self.cellType = "\(AnimeStoryListCell.self)"
        self.collectionType = CollectionType.Story
    }
    
    static func ==(_ lhs : AnimeStory, _ rhs : AnimeStory) -> Bool {
        return lhs.id == rhs.id
    }
}
