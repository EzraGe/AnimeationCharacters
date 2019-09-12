//
//  CharacterListCell.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/4.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class CharacterListCell : FeedListBaseCell, FavouriteCell {
    var like: (FeedListModel) -> () = {_ in }
    
    var cancelFavourite: (FeedListModel) -> () = {_ in}
    
    private var avatorView = UIImageView()
    private var nameLabel = UILabel()
    private var cvLabel = UILabel()
    internal var favourBtn = FavouriteButton()
    
    private var data : Character?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.updateSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(with data: FeedListModel, at indexPath: IndexPath) {
        if type(of: data) == Character.self {
            let character : Character = data as! Character
            self.data = character
            self.avatorView.sd_setImage(with: URL.init(string: character.avator), completed: nil)
            self.nameLabel.text = character.name
            self.cvLabel.text = "cv : \(character.cv)"
        }
    }
    
    override class func cellHeight(for data: FeedListModel) -> CGFloat {
        return 104
    }
    
    func updateSubviews() {
        let square : CGFloat = 64
        let y = (74 - square) * 0.5
        self.avatorView.contentMode = UIView.ContentMode.scaleAspectFill
        self.avatorView.cornerRadius = 0.5 * square
        self.avatorView.clipsToBounds = true
        self.detailContentView.addSubview(self.avatorView)
        self.avatorView.snp.remakeConstraints { (_ make: ConstraintMaker) in
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(square)
            make.top.equalToSuperview().offset(y)
        }
        
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.nameLabel.textColor = UIColor.Theme.black333333
        self.detailContentView.addSubview(self.nameLabel)
        self.nameLabel.snp.remakeConstraints { (_ make : ConstraintMaker) in
            make.left.equalTo(self.avatorView.snp.right).offset(15)
            make.height.equalTo(29)
            make.width.equalTo(screenWidth - 40 - 20 - 15 - square - favouriteBtnSquare)
            make.top.equalTo(self.avatorView).offset(5)
        }
        
        self.cvLabel.font = UIFont.PingFangSC_Regular(size: 17)
        self.cvLabel.textColor = UIColor.Theme.black333333
        self.detailContentView.addSubview(self.cvLabel)
        self.cvLabel.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.width.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(5)
            make.height.equalTo(20)
        }
        
        self.detailContentView.addSubview(self.favourBtn)
        self.favourBtn.snp.remakeConstraints { (_ make : ConstraintMaker) in
            make.width.height.equalTo(favouriteBtnSquare)
            make.centerY.equalTo(self.avatorView)
            make.right.equalToSuperview().offset(-5)
        }
        self.favourBtn.addTarget(self, action: #selector(onFavourBtnClick(_:)), for: .touchUpInside)
    }
    
    @objc func onFavourBtnClick(_ btn : FavouriteButton) {
        if btn.isSelected {
            self.cancelFavourite(self.data!)
        } else {
            if self.data != nil {
                self.like(self.data!)
            }
        }
    }
}
