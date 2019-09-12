//
//  Bundle.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/10.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation

extension Bundle {
    class func lineURL(with lineID : Int) -> URL? {
        let pathOfBundle : String = Bundle.main.path(forResource: "LineBundle", ofType: "bundle")!
        let filePath = pathOfBundle.appendingPathComponent("\(lineID).mp3")
        return URL.init(string: filePath)
    }
}
