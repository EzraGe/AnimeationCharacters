//
//  String.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/5.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import Foundation

extension String {
    func byInsertingAppNameBefore() -> String {
        let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        return appName + "." + "\(self)"
    }
}
