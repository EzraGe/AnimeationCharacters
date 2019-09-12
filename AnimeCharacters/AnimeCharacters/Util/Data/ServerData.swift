//
//  ServerData.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/30.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation

class Server {
    static let sharedServer = Server()
    
    class func getStoryList() -> Array<Dictionary<String, Any>> {
        var storyList = Array<Dictionary<String, Any>>()
        
        storyList.append(
            ["story_name_chs" : "叛逆的鲁路修",
             "story_name_cht" : "叛逆的魯路修",
             "story_name_jap" : "コードギアス 反逆のルルーシュ",
             "story_name_eng" : "code geass",
             "back_image" : "http://i0.hdslb.com/bfs/article/aa5826e1566bf5dd16885234f15f1eb976cd3778.jpg"
            ]
        )
        
        return storyList
    }
}
