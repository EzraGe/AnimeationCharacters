//
//  Profile.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/15.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol BasicProfile {
    var id : Int { get set }
    var imgURL : String { get set }
    var name : String { get set }
    var introduction : String { get set }
}

protocol HumanProfile {
    var nickname : [String] { get set }
    var sex : Bool { get set }
    var birthday : String { get set }
    var bloodType : String { get set }
    var constellation : String { get set }
}

struct CastElement {
    var character : Character
    var actor : VoiceActor
    
    init(character : Character, actor : VoiceActor) {
        self.character = character
        self.actor = actor
    }
}

struct AnimeStoryProfile : BasicProfile {
    var id: Int
    
    var imgURL: String
    
    var name: String
    
    var introduction: String
    
    var typeTags : [String]
    
    var firstShowTime : String
    
    var score : Float
    
    var seasonInfo : String
    
    var cast : [CastElement]
    
    init(with json : JSON) {
        let data = json["data"]["profile"].dictionaryValue
        self.id = data["id"]!.intValue
        self.imgURL = data["img_url"]!.stringValue
        self.name = data["story_name"]!.stringValue
        self.introduction = data["introduction"]!.stringValue
        self.typeTags = data["types"]!.arrayValue.map({$0.stringValue})
        self.firstShowTime = data["time"]!.stringValue
        self.score = data["score"]!.floatValue
        self.seasonInfo = data["season_info"]!.stringValue
        self.cast = data["cast"]!.arrayValue.map({ (_ element : JSON) -> CastElement in
            let characterDict   = element["character"].dictionaryValue
            let voice_actorDict = element["voice_actor"].dictionaryValue
            let character = Character.init(id: characterDict["id"]!.intValue, name: characterDict["name"]!.stringValue, avator: characterDict["avator"]!.stringValue, cv: characterDict["cv"]!.stringValue)
            let voiceActor = VoiceActor.init(id: voice_actorDict["id"]!.intValue, name: voice_actorDict["name"]!.stringValue, avator: voice_actorDict["avator"]!.stringValue)
            return CastElement.init(character: character, actor: voiceActor)
        })
    }
}

struct CharacterProfile : BasicProfile, HumanProfile {
    var id: Int
    
    var introduction: String
    
    var imgURL: String
    
    var name: String
    
    var englishName : String
    
    var nickname: [String]
    
    var sex: Bool
    
    var birthday: String
    
    var bloodType: String
    
    var constellation: String
    
    var story : String
    
    var height : String
    
    var weight : String
    
    var character : Character
    
    var voiceActor : VoiceActor
    
    var lines : [LineModel]
    
    init(with json : JSON) {
        let data = json["data"]["profile"].dictionaryValue
        let url = data["img_url"]!.stringValue
        
        self.id = data["id"]!.intValue
        self.imgURL = url
        self.name = data["name"]!.stringValue
        self.englishName = data["name_eng"]!.stringValue
        self.introduction = data["introduction"]!.stringValue
        self.nickname = data["nickname"]!.arrayValue.map({$0.stringValue})
        self.sex = data["sex"]!.boolValue
        self.birthday = data["birthday"]!.stringValue
        self.bloodType = data["blood_type"]!.stringValue
        self.constellation = data["constellation"]!.stringValue
        self.story = data["story"]!.stringValue
        self.height = data["height"]!.stringValue
        self.weight = data["weight"]!.stringValue
        let characterDict   = data["character"]!.dictionaryValue
        let voice_actorDict = data["voice_actor"]!.dictionaryValue
        self.character = Character.init(id: characterDict["id"]!.intValue, name: characterDict["name"]!.stringValue, avator: characterDict["avator"]!.stringValue, cv: characterDict["cv"]!.stringValue)
        self.voiceActor = VoiceActor.init(id: voice_actorDict["id"]!.intValue, name: voice_actorDict["name"]!.stringValue, avator: voice_actorDict["avator"]!.stringValue)
        
        self.lines = data["lines"]!.arrayValue.map({ (_ element : JSON) -> LineModel in
            let id = element["id"].intValue
            let line = element["line"].stringValue
            let cha = Character.init(id: characterDict["id"]!.intValue, name: characterDict["name"]!.stringValue, avator: characterDict["avator"]!.stringValue, cv: characterDict["cv"]!.stringValue)
            let voa = VoiceActor.init(id: voice_actorDict["id"]!.intValue, name: voice_actorDict["name"]!.stringValue, avator: voice_actorDict["avator"]!.stringValue)
            
            return LineModel.init(id: id, from: cha, from: voa, line: line, backgroundURL: url)
        })
    }
    
    func titleArray() -> [String] {
        return ["name", "english name", "nickname", "sex", "height", "weight", "birthday", "constellation" , "blood type", "story", "cv"]
    }
    
    func contentArray() -> [String] {
        return [self.name, self.englishName, (self.nickname as NSArray).componentsJoined(by: ","), self.sex ? "Male" : "Female", self.height, self.weight, self.birthday, self.constellation, self.bloodType, self.story, self.voiceActor.name]
    }
}

struct VoiceActorProfile : BasicProfile, HumanProfile {
    var id: Int
    
    var introduction: String
    
    var imgURL: String
    
    var name: String
    
    var englishName : String
    
    var nickname: [String]
    
    var sex: Bool
    
    var birthday: String
    
    var bloodType: String
    
    var constellation: String
    
    var company : String
    
    var characterList : [Character]
    
    func titleArray() -> [String] {
        return ["name", "english name", "nickname", "sex", "birthday", "constellation" , "blood type", "company"]
    }
    
    func contentArray() -> [String] {
        return [self.name, self.englishName, (self.nickname as NSArray).componentsJoined(by: ","), self.sex ? "Male" : "Female", self.birthday, self.constellation, self.bloodType, self.company]
    }
    
    init(with json : JSON) {
        let data = json["data"]["profile"].dictionaryValue
        let url = data["img_url"]!.stringValue
        
        self.id = data["id"]!.intValue
        self.imgURL = url
        self.name = data["name"]!.stringValue
        self.englishName = data["name_eng"]!.stringValue
        self.introduction = data["introduction"]!.stringValue
        self.nickname = data["nickname"]!.arrayValue.map({$0.stringValue})
        self.sex = data["sex"]!.boolValue
        self.birthday = data["birthday"]!.stringValue
        self.bloodType = data["blood_type"]!.stringValue
        self.constellation = data["constellation"]!.stringValue
        self.company = data["company"]!.stringValue
        
        self.characterList = data["characterList"]!.arrayValue.map({ (_ element : JSON) -> Character in
            let characterDict   = element["character"].dictionaryValue
            return Character.init(id: characterDict["id"]!.intValue, name: characterDict["name"]!.stringValue, avator: characterDict["avator"]!.stringValue, cv: characterDict["cv"]!.stringValue)
        })
    }
}
