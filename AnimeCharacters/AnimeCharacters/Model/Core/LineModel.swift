//
//  VoiceModel.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/6.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation

struct LineModel : CollectionModel, Equatable , Codable {
    
    var collectionType: CollectionType
    
    let id : Int
    let voiceActor : VoiceActor
    let character : Character
    let line : String
    let url : URL?
    let backgroundURL : String
    
    init(id : Int, from character : Character, from voiceActor : VoiceActor, line : String, backgroundURL : String) {
        self.id = id
        self.url = Bundle.lineURL(with: id)
        self.character = character
        self.voiceActor = voiceActor
        self.line = line
        self.collectionType = CollectionType.Line
        self.backgroundURL = backgroundURL
    }
    
    static func ==(_ lhs : LineModel, _ rhs : LineModel) -> Bool {
        return lhs.id == rhs.id
    }
}
