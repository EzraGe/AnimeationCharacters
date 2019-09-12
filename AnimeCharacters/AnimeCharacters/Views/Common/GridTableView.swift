//
//  GridTableView.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/19.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

class GridTableview : UIView {
    var titleArray : [String]?
    var contentsArray : [String]?
    var titleColumnWidthRatio : CGFloat = 0.2 {
        didSet {
            self.layoutSubviews()
        }
    }
    
    var hideBorderLine = false {
        willSet {
            let lines = [self.headSeperatorLineVertical, self.midSeperatorLine, self.tailSeperatorLineVerticle, self.horizontalLineTop] + self.horizontalLines
            lines.forEach { (line) in
                line.isHidden = newValue
            }
        }
    }
    
    private var seperatorLineWidth : CGFloat = 1
    private var rowHeight : CGFloat = 30
    
    var horizontalLineTop = UIView()
    var headSeperatorLineVertical = UIView()
    var midSeperatorLine = UIView()
    var tailSeperatorLineVerticle = UIView()
    
    var titleLables = [UILabel]()
    var contentScrollViews = [UIScrollView]()
    var contentLabels = [UILabel]()
    var horizontalLines = [UIView]()
    
    var font : UIFont = UIFont.PingFangSC_Regular(size: 16) {
        didSet {
            self.updateFonts()
        }
    }
    
    func estimatedHeight() -> CGFloat {
        return (self.rowHeight + self.seperatorLineWidth) * CGFloat(self.titleArray!.count) + 2 * self.seperatorLineWidth
    }
    
    init(_ frame : CGRect, titleArray : [String], contentsArray : [String]) {
        guard titleArray.count == contentsArray.count else {
            fatalError("Row number error!")
        }
        
        super.init(frame: frame)
        self.titleArray = titleArray
        self.contentsArray = contentsArray
        
        self.horizontalLineTop.backgroundColor = UIColor.Theme.black333333
        self.addSubview(self.horizontalLineTop)
        self.headSeperatorLineVertical.backgroundColor = UIColor.Theme.black333333
        self.addSubview(self.headSeperatorLineVertical)
        self.midSeperatorLine.backgroundColor = UIColor.Theme.black333333
        self.addSubview(self.midSeperatorLine)
        self.tailSeperatorLineVerticle.backgroundColor = UIColor.Theme.black333333
        self.addSubview(self.tailSeperatorLineVerticle)
        
        for i in 0..<titleArray.count {
            let label = UILabel()
            label.font = self.font
            label.text = titleArray[i]
            self.addSubview(label)
            self.titleLables.append(label)
            
            let scrollview = UIScrollView()
            scrollview.alwaysBounceHorizontal = true
            scrollview.showsHorizontalScrollIndicator = false
            self.addSubview(scrollview)
            self.contentScrollViews.append(scrollview)
            
            let contentLabel = UILabel()
            contentLabel.font = self.font
            contentLabel.text = contentsArray[i]
            scrollview.addSubview(contentLabel)
            self.contentLabels.append(contentLabel)
            
            let bottomLine = UIView()
            bottomLine.backgroundColor = UIColor.Theme.black333333
            self.addSubview(bottomLine)
            self.horizontalLines.append(bottomLine)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFonts() {
        for label in self.titleLables {
            label.font = self.font
        }
        for label in self.contentLabels {
            label.font = self.font
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = self.titleArray!.count
        let titleW = self.titleColumnWidthRatio * (self.width - 3 * self.seperatorLineWidth)
        let contentW = self.width - titleW
        
        self.headSeperatorLineVertical.frame = .init(x: 0, y: 0, width: self.seperatorLineWidth, height: self.height)
        self.midSeperatorLine.frame = .init(x: self.headSeperatorLineVertical.frame.maxX + titleW, y: 0, width: self.seperatorLineWidth, height: self.height)
        self.tailSeperatorLineVerticle.frame = .init(x: self.width - self.seperatorLineWidth, y: 0, width: self.seperatorLineWidth, height: self.height)
        
        var y : CGFloat = 0
        self.horizontalLineTop.frame = .init(x: 0, y: 0, width: self.width, height: self.seperatorLineWidth)
        y += self.seperatorLineWidth
        
        for i in 0 ..< count {
            let titleLabel = self.titleLables[i]
            titleLabel.frame = .init(x: 0, y: y, width: titleW, height: self.rowHeight)
            
            let scrollview = self.contentScrollViews[i]
            scrollview.frame = .init(x: self.midSeperatorLine.frame.maxX, y: y, width: contentW, height: self.rowHeight)
            
            let contentLabel = self.contentLabels[i]
            var w = (contentLabel.text! as NSString).boundingRect(with: .init(width: CGFloat.greatestFiniteMagnitude, height: self.rowHeight), options: .usesLineFragmentOrigin, attributes: ([NSAttributedString.Key.font : self.font] as Any as! [NSAttributedString.Key : Any]), context: nil).width
            w = ceil(w)
            contentLabel.frame = .init(x: 0, y: 0, width: w, height: self.rowHeight)
            scrollview.contentSize = .init(width: w, height: self.rowHeight)
            
            y += self.rowHeight
            
            let bottomLine = self.horizontalLines[i]
            bottomLine.frame = .init(x: 0, y: y, width: self.width, height: self.seperatorLineWidth)
            
            y += self.seperatorLineWidth
        }
    }
}
