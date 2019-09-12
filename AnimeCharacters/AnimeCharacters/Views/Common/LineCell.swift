//
//  LineCell.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/21.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SnapKit

class LineCell : UITableViewCell {
    var data : LineModel?
    
    var showLineTag = false {
        didSet {
            self.layoutSubviews()
        }
    }
    
    private var lineLabel = UILabel()
    private var characterLabel = UILabel()
    private var cvLabel = UILabel()
    private var tagView = FavouriteCellTag()
    
    override class func cellHeight(for data : Any?) -> CGFloat {
        return 64
    }
    
    override func updateWith(data: AnyObject?, indexPath: IndexPath) {
        super.updateWith(data: data, indexPath: indexPath)
        let line = data as! LineModel
        self.data = line
        self.lineLabel.text = line.line
        self.tagView.snp.updateConstraints { (_ make : ConstraintMaker) in
            make.width.equalTo(self.showLineTag ? self.tagView.textWidth + 10 : 0)
        }
        
        let name = line.character.name
        self.characterLabel.text = name
        let w = (self.characterLabel.text! as NSString).boundingRect(with: .init(width: CGFloat.greatestFiniteMagnitude, height: 25), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : self.characterLabel.font as Any], context: nil).width
        self.characterLabel.snp.updateConstraints { (_ make : ConstraintMaker) in
            make.width.equalTo(ceil(w))
            make.left.equalTo(self.tagView.snp.right).offset(self.showLineTag ? 8 : 0)
        }
        self.cvLabel.text = " (cv:\(line.voiceActor.name))"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.updateSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSubviews() {
        let padding : CGFloat = 15
        let v_padding : CGFloat = 4
        let textColor = UIColor.Theme.black333333
        
        self.lineLabel.textColor = textColor
        self.lineLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentView.addSubview(self.lineLabel)
        self.lineLabel.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.equalToSuperview().offset(padding)
            make.right.equalToSuperview().offset(-padding)
            make.top.equalToSuperview().offset(v_padding)
            make.height.equalTo(24)
        }
        
        self.contentView.addSubview(self.tagView)
        self.tagView.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.equalTo(self.lineLabel)
            make.top.equalTo(self.lineLabel.snp.bottom).offset(4)
            make.height.equalTo(25)
            make.width.equalTo(0)
        }
        self.tagView.cornerRadius = 5
        self.tagView.clipsToBounds = true
        self.tagView.type = .Line
        
        self.characterLabel.textColor = textColor
        self.characterLabel.font = UIFont.PingFangSC_Regular(size: 12)
        self.contentView.addSubview(self.characterLabel)
        self.characterLabel.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.equalTo(self.tagView.snp.right).offset(8)
            make.width.equalTo(0)
            make.top.equalTo(self.lineLabel.snp.bottom).offset(4)
            make.height.equalTo(25)
        }
        
        self.cvLabel.textColor = textColor
        self.cvLabel.font = UIFont.PingFangSC_Regular(size: 12)
        self.contentView.addSubview(self.cvLabel)
        self.cvLabel.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.equalTo(self.characterLabel.snp.right).offset(4)
            make.right.equalToSuperview().offset(-padding)
            make.centerY.height.equalTo(self.characterLabel)
        }
    }
}
