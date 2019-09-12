//
//  AnimeStoryDetailCastCell.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/22.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class AnimeStoryDetailCastCell : UITableViewCell {
    
    var clickCharacterAvatorViewHandler  : (_ id : Int) -> () = {_ in }
    var clickVoiceActorAvatorViewHandler : (_ id : Int) -> () = {_ in }
    
    private var data : CastElement?
    private var characterAvatorView  = UIImageView()
    private var characterLabel       = UILabel()
    private var voiceActorAvatorView = UIImageView()
    private var voiceActorLabel      = UILabel()
    
    override func updateWith(data: AnyObject?, indexPath: IndexPath) {
        super.updateWith(data: data, indexPath: indexPath)
        let castElementOp = data as? CastElement
        if castElementOp != nil {
            let castElement = castElementOp!
            self.data = castElement
            let placeholderColor = UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            self.characterAvatorView.sd_setImage(with: URL.init(string: castElement.character.avator), placeholderImage: UIImage.imageWithColor(placeholderColor), options: SDWebImageOptions.retryFailed, completed: nil)
            self.voiceActorAvatorView.sd_setImage(with: URL.init(string: castElement.actor.avator), placeholderImage: UIImage.imageWithColor(placeholderColor), options: SDWebImageOptions.retryFailed, completed: nil)
            self.characterLabel.text = castElement.character.name
            self.voiceActorLabel.text = castElement.actor.name
        }
    }
    
    override class func cellHeight(for data : Any?) -> CGFloat {
        return 64 + 10 + 25 + 12
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
    
    // MARK: subviews
    
    func updateSubviews() {
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
        
        let square : CGFloat = 64
        let space : CGFloat = 10
        let labelH : CGFloat = 25
        let padding_v : CGFloat = 6
        let padding_h : CGFloat = (screenWidth - square * 2) / 3
        
        self.characterAvatorView.contentMode = .scaleAspectFill
        self.characterAvatorView.cornerRadius = 0.5 * square;
        self.characterAvatorView.clipsToBounds = true
        self.characterAvatorView.isUserInteractionEnabled = true
        let gestureChara = UITapGestureRecognizer.init(target: self, action: #selector(clickCharacterView))
        gestureChara.delegate = self
        self.characterAvatorView.addGestureRecognizer(gestureChara)
        self.contentView.addSubview(self.characterAvatorView)
        self.characterAvatorView.snp.makeConstraints { (_ make :ConstraintMaker) in
            make.width.height.equalTo(square)
            make.top.equalToSuperview().offset(padding_v)
            make.left.equalToSuperview().offset(padding_h)
        }
        
        self.characterLabel.textAlignment = .center
        self.contentView.addSubview(self.characterLabel)
        self.characterLabel.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.top.equalTo(self.characterAvatorView.snp.bottom).offset(space)
            make.height.equalTo(labelH)
            make.centerX.equalTo(self.characterAvatorView)
            make.width.equalTo(0.5 * screenWidth)
        }
        
        self.voiceActorAvatorView.contentMode = .scaleAspectFill
        self.voiceActorAvatorView.cornerRadius = 0.5 * square;
        self.voiceActorAvatorView.clipsToBounds = true
        self.voiceActorAvatorView.isUserInteractionEnabled = true
        let voiceGesture = UITapGestureRecognizer.init(target: self, action: #selector(clickVoiceActorView))
        voiceGesture.delegate = self
        self.voiceActorAvatorView.addGestureRecognizer(voiceGesture)
        self.contentView.addSubview(self.voiceActorAvatorView)
        self.voiceActorAvatorView.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.equalTo(self.characterAvatorView.snp.right).offset(padding_h)
            make.width.height.equalTo(square)
            make.top.equalToSuperview().offset(padding_v)
        }
        
        self.voiceActorLabel.textAlignment = .center
        self.contentView.addSubview(self.voiceActorLabel)
        self.voiceActorLabel.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.top.height.width.equalTo(self.characterLabel)
            make.centerX.equalTo(self.voiceActorAvatorView)
        }
    }
    
    @objc func clickCharacterView() {
        if self.data != nil {
            self.clickCharacterAvatorViewHandler(self.data!.character.id)
        }
    }
    
    @objc func clickVoiceActorView() {
        if self.data != nil {
            self.clickVoiceActorAvatorViewHandler(self.data!.actor.id)
        }
    }
    
    //MARK: UIGestureRecognizerDelegate
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if type(of: gestureRecognizer.view) == UIImageView.self {
            return true
        }
        return false
    }
}
