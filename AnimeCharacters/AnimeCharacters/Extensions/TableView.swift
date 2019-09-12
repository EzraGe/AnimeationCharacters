//
//  TableView.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/29.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

extension UITableViewCell : CellReusable {
    static var cellReuseIdentifier: String {
        return "\(self)"
    }
    
    @objc class func cellHeight(for data : Any?) -> CGFloat {
        return 0
    }
    
    @objc func updateWith(data : AnyObject?, indexPath : IndexPath) {
        
    }
}

extension UITableView {
    func reloadDataWithUpdates() {
        self.beginUpdates()
        self.reloadData()
        self.endUpdates()
    }
    
    func reloadRowsWithUpdates(at indexPaths : [IndexPath] , with animation : UITableView.RowAnimation) {
        self.beginUpdates()
        self.reloadRows(at: indexPaths, with: animation)
        self.endUpdates()
    }
    
    func reloadSectionsWithUpdates(_ sections : IndexSet, with animation : UITableView.RowAnimation) {
        self.beginUpdates()
        self.reloadSections(sections, with: animation)
        self.endUpdates()
    }
}
