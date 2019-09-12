//
//  Array.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/26.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation

let ArrayElementNotFound = -1

extension Array {
    func indexOf(_ ele : Element, comparation : (_ e1 : Element, _ e2 : Element) -> (Bool)) -> Int {
        var index = ArrayElementNotFound
        
        var i = 0
        for e : Element in self {
            if comparation(ele, e) {
                index = i
                break
            }
            i += 1
        }
        
        return index
    }
}
