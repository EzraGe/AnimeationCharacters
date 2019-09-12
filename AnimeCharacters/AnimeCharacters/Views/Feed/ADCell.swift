//
//  ADCell.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/5.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import QuartzCore

class RemoveButton : UIButton {
    override func draw(_ rect: CGRect) {
        let padding : CGFloat = 0.1 * rect.width
        let path = UIBezierPath.init()
        UIColor.white.setStroke()
        path.lineJoinStyle = .round
        path.lineWidth = 2
        path.move(to: .init(x: padding, y: padding))
        path.addLine(to: .init(x: rect.width - padding, y: rect.height - padding))
        path.move(to: .init(x: padding, y: rect.height - padding))
        path.addLine(to: .init(x: rect.width - padding, y: padding))
        path.stroke()
    }
}

class ADCell : FeedListBaseCell {
    private var adTitleLabel = UILabel()
    private var seperatorLine = UIView()
    private var adLabel = UILabel()
    private var removeButton = RemoveButton()
    
    var removeCallback : () -> () = {}
    
    override class func cellHeight(for data: FeedListModel) -> CGFloat {
        return 116
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.updateSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSubviews() {
        let adPadding : CGFloat = 15
        self.adTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.adTitleLabel.textColor = UIColor.Theme.black333333
        self.detailContentView.addSubview(self.adTitleLabel)
        self.adTitleLabel.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.equalToSuperview().offset(adPadding)
            make.right.equalToSuperview().offset(-adPadding)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(30)
        }
        
        self.seperatorLine.backgroundColor = UIColor.FlatUI.clouds
        self.detailContentView.addSubview(self.seperatorLine)
        self.seperatorLine.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.right.equalTo(self.adTitleLabel)
            make.top.equalTo(self.adTitleLabel.snp.bottom).offset(5)
            make.height.equalTo(1)
        }
        
        self.adLabel.font = UIFont.PingFangSC_Regular(size: 16)
        self.adLabel.textColor = UIColor.Theme.black333333
        self.detailContentView.addSubview(self.adLabel)
        self.adLabel.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.height.equalTo(30)
            make.left.right.equalTo(self.seperatorLine)
            make.top.equalTo(self.seperatorLine.snp.bottom).offset(5)
        }
        
        self.detailContentView.addSubview(self.removeButton)
        let padding : CGFloat = 15
        let square : CGFloat = 16
        self.removeButton.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.centerY.equalTo(self.adTitleLabel)
            make.right.equalTo(self.detailContentView).offset(-padding)
            make.width.height.equalTo(square)
        }
        self.removeButton.addTarget(self, action: #selector(onRemoveButtonClick), for: .touchUpInside)
    }
    
    @objc func onRemoveButtonClick() {
        self.removeCallback()
    }
    
    override func update(with data: FeedListModel, at indexPath: IndexPath) {
        super.update(with: data, at: indexPath)
        let adModel : ADModel = data as! ADModel
        self.adTitleLabel.text = "Advertisement"
        self.adLabel.text = "\(adModel.name) \(adModel.description)"
    }
}
