//
//  AnimeStoryListCell.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/30.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

class AnimeStoryListCell : FeedListBaseCell, FavouriteCell {
    var like: (FeedListModel) -> () = {_ in}
    
    var cancelFavourite: (FeedListModel) -> () = {_ in}
    
    static private let cellHeightVar = (screenWidth - 60) / 1.6 + 40 + 80
    
    private var nameLabel = UILabel()
    private var onlineTimeLabel = UILabel()
    private var backImageView = UIImageView()
    internal var favourBtn = FavouriteButton()
    
    private var data : AnimeStory?
    
    override func update(with data: FeedListModel, at indexPath: IndexPath) {
        let story : AnimeStory = data as! AnimeStory
        if type(of: story) == AnimeStory.self {
            self.data = story
            self.nameLabel.text = story.name
            self.onlineTimeLabel.text = story.onlineTime
            
            let placeholderColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            self.backImageView.sd_setImage(with: URL.init(string: story.backImageURL), placeholderImage: UIImage.imageWithColor(placeholderColor), options: SDWebImageOptions.retryFailed, completed: nil)
            self.layoutSubviews()
        }
    }
    
    override class func cellHeight(for data: FeedListModel) -> CGFloat {
        return cellHeightVar
    }
    
    // MARK: init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.updateSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: subviews
    
    func updateSubviews() {
        self.detailContentView.addSubview(self.backImageView)
        self.backImageView.contentMode = .scaleAspectFill
        self.backImageView.clipsToBounds = true
        self.backImageView.snp.remakeConstraints { (_ make: ConstraintMaker) in
            make.left.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo((screenWidth - 40 - 20) / 1.6)
        }
        
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        self.nameLabel.textColor = UIColor.Theme.black333333
        self.detailContentView.addSubview(self.nameLabel)
        self.nameLabel.snp.remakeConstraints { (_ make : ConstraintMaker) in
            make.left.width.equalTo(self.backImageView)
            make.top.equalTo(self.backImageView.snp.bottom).offset(5)
            make.height.equalTo(30)
        }
        
        self.onlineTimeLabel.font = UIFont.systemFont(ofSize: 18)
        self.onlineTimeLabel.textColor = self.nameLabel.textColor
        self.detailContentView.addSubview(self.onlineTimeLabel)
        self.onlineTimeLabel.snp.remakeConstraints { (_ make : ConstraintMaker) in
            make.left.width.equalTo(self.backImageView)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(7)
            make.height.equalTo(28)
        }
        
        self.detailContentView.addSubview(self.favourBtn)
        self.favourBtn.snp.remakeConstraints { (_ make : ConstraintMaker) in
            make.width.height.equalTo(favouriteBtnSquare)
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalTo(self.onlineTimeLabel)
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
