//
//  DB.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/16.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

var CancelFavouriteNotification = "CancelFavouriteNotification"

class Favourites {
    static let sharedInstance = Favourites()
    
    /// save favourite state
    fileprivate var storyState : Dictionary<Int, AnimeStory> = [:]
    fileprivate var characterState : Dictionary<Int, Character> = [:]
    fileprivate var voiceActorState : Dictionary<Int, VoiceActor> = [:]
    fileprivate var lineState : Dictionary<Int, LineModel> = [:]
    
    init() {
        let s_data : Data? = UserDefaults.standard.value(forKey: "story") as? Data
        if (s_data != nil) {
            self.storyState = try! JSONDecoder().decode([Int : AnimeStory].self, from: s_data!)
        } else {
            self.storyState = [:]
        }
        
        let c_data : Data? = UserDefaults.standard.value(forKey: "character") as? Data
        if (c_data != nil) {
            self.characterState = try! JSONDecoder().decode([Int : Character].self, from: c_data!)
        } else {
            self.characterState = [:]
        }
        
        let v_data : Data? = UserDefaults.standard.value(forKey: "voice_actor") as? Data
        if (v_data != nil) {
            self.voiceActorState = try! JSONDecoder().decode([Int : VoiceActor].self, from: v_data!)
        } else {
            self.voiceActorState = [:]
        }
        
        let l_data : Data? = UserDefaults.standard.value(forKey: "line") as? Data
        if (l_data != nil) {
            self.lineState = try! JSONDecoder().decode([Int : LineModel].self, from: l_data!)
        } else {
            self.lineState = [:]
        }
    }
    
    func persist(_ data : Any , completion : (_ success : Bool) -> () ) {
        if type(of: data) == AnimeStory.self {
            let value = data as! AnimeStory
            self.storyState[value.id] = value
            let data : Data = try! JSONEncoder().encode(self.storyState)
            UserDefaults.standard.setValue(data, forKey: "story")
        } else if type(of: data) == Character.self {
            let value = data as! Character
            self.characterState[value.id] = value
            let data : Data = try! JSONEncoder().encode(self.characterState)
            UserDefaults.standard.setValue(data, forKey: "character")
        } else if type(of: data) == VoiceActor.self {
            let value = data as! VoiceActor
            self.voiceActorState[value.id] = value
            let data : Data = try! JSONEncoder().encode(self.voiceActorState)
            UserDefaults.standard.setValue(data, forKey: "voice_actor")
        } else if type(of: data) == LineModel.self {
            let value = data as! LineModel
            self.lineState[value.id] = value
            let data : Data = try! JSONEncoder().encode(self.lineState)
            UserDefaults.standard.setValue(data, forKey: "line")
        } else {
            return
        }
        let success = UserDefaults.standard.synchronize()
        completion(success)
    }
    
    func unpersist(_ data : Any, completion : (_ success : Bool) -> ()) {
        if type(of: data) == AnimeStory.self {
            let value = data as! AnimeStory
            self.storyState.removeValue(forKey: value.id)
            let data : Data = try! JSONEncoder().encode(self.storyState)
            UserDefaults.standard.setValue(data, forKey: "story")
        } else if type(of: data) == Character.self {
            let value = data as! Character
            self.characterState.removeValue(forKey: value.id)
            let data : Data = try! JSONEncoder().encode(self.characterState)
            UserDefaults.standard.setValue(data, forKey: "character")
        } else if type(of: data) == VoiceActor.self {
            let value = data as! VoiceActor
            self.voiceActorState.removeValue(forKey: value.id)
            let data : Data = try! JSONEncoder().encode(self.voiceActorState)
            UserDefaults.standard.setValue(data, forKey: "voice_actor")
        } else if type(of: data) == LineModel.self {
            let value = data as! LineModel
            self.lineState.removeValue(forKey: value.id)
            let data : Data = try! JSONEncoder().encode(self.lineState)
            UserDefaults.standard.setValue(data, forKey: "line")
        } else {
            return
        }
        
        let success = UserDefaults.standard.synchronize()
        completion(success)
    }
    
    func isFavourited(data : Any) -> Bool {
        if type(of: data) == AnimeStory.self {
            let value = data as! AnimeStory
            return self.storyState.has(key: value.id)
        } else if type(of: data) == Character.self {
            let value = data as! Character
            return self.characterState.has(key: value.id)
        } else if type(of: data) == VoiceActor.self {
            let value = data as! VoiceActor
            return self.voiceActorState.has(key: value.id)
        } else if type(of: data) == LineModel.self {
            let value = data as! LineModel
            return self.lineState.has(key: value.id)
        } else {
            return false
        }
    }
    
    func allCollection() -> [CollectionModel] {
        return self.storyCollection() + self.characterCollection() + self.voiceActorCollection() + self.lineCollection()
    }
    
    func storyCollection() -> [CollectionModel] {
        var collection = [CollectionModel]()
        for story in self.storyState.values {
            let collectionModel = story as CollectionModel
            collection.append(collectionModel)
        }
        return collection
    }
    
    func characterCollection() -> [CollectionModel] {
        var collection = [CollectionModel]()
        for c in self.characterState.values {
            let collectionModel = c as CollectionModel
            collection.append(collectionModel)
        }
        return collection
    }
    
    func voiceActorCollection() -> [CollectionModel] {
        var collection = [CollectionModel]()
        for v in self.voiceActorState.values {
            let collectionModel = v as CollectionModel
            collection.append(collectionModel)
        }
        return collection
    }
    
    func lineCollection() -> [CollectionModel] {
        var collection = [CollectionModel]()
        for line in self.lineState.values {
            let collectionModel = line as CollectionModel
            collection.append(collectionModel)
        }
        return collection
    }
}

extension Favourites {
    func numberOfRows(_ option : DropDownOption) -> Int {
        switch option {
        case .all:
            return self.storyState.count + self.characterState.count + self.voiceActorState.count + self.lineState.count
        case .story:
            return self.storyState.count
        case .character:
            return self.characterState.count
        case .voiceActor:
            return self.voiceActorState.count
        case .line:
            return self.lineState.count
        }
    }
    
    func currentDataSource(_ option : DropDownOption) -> [CollectionModel] {
        switch option {
        case .all:
            return self.allCollection()
        case .story:
            return self.storyCollection()
        case .character:
            return self.characterCollection()
        case .voiceActor:
            return self.voiceActorCollection()
        case .line:
            return self.lineCollection()
        }
    }
}
