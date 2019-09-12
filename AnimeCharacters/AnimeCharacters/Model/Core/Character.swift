//
//  Character.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/29.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation

struct Character : FeedListModel , CollectionModel, Equatable , Codable {
    var collectionType: CollectionType
    
    var id : Int
    var cellType: String
    let name : String
    var avator : String
    var cv : String
    
    init(id : Int, name : String, avator : String, cv : String) {
        self.id = id
        self.name = name
        self.avator = avator
        self.cv = cv
        self.cellType = "\(CharacterListCell.self)"
        self.collectionType = CollectionType.Character
    }
    
    static func ==(_ lhs : Character, _ rhs : Character) -> Bool {
        return lhs.id == rhs.id
    }
}


