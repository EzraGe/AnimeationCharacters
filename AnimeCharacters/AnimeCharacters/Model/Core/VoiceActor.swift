//
//  VoiceActor.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/29.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation

struct VoiceActor : FeedListModel, CollectionModel, Equatable, Codable {
    
    var collectionType: CollectionType
    var id : Int
    
    var cellType: String
    var name : String
    var avator : String
    
    init(id : Int, name : String, avator : String) {
        self.id = id
        self.name = name
        self.avator = avator
        self.cellType = "\(VoiceActorListCell.self)"
        self.collectionType = CollectionType.VoiceActor
    }
    
    static func ==(_ lhs : VoiceActor, _ rhs : VoiceActor) -> Bool {
        return lhs.id == rhs.id
    }
}
