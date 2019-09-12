//
//  VoiceActorDetailController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/30.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SwiftyJSON

class VoiceActorDetailController: BaseController {
    private var actorId : Int = 0
    
    private var profile : VoiceActorProfile?
    
    private var backImageView = UIImageView()
    private var effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
    private var gridview : GridTableview?
    private var introLabel = UILabel()
    private var bodyScrollview = UIScrollView()
    private var actorImageview = UIImageView()
    
    init(with actorId : Int) {
        super.init(nibName: nil, bundle: nil)
        self.actorId = actorId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ac_navigationBarHidden = false
        self.ac_navigationBarBackButtonStyle = .white
        
        self.backImageView.frame = self.view.bounds
        self.backImageView.contentMode = .scaleAspectFill
        self.backImageView.clipsToBounds = true
        self.view.addSubview(self.backImageView)
        
        self.bodyScrollview.frame = .init(x: 0, y: statusBarHeight + navigationBarHeight, width: self.view.width, height: self.view.height - statusBarHeight - navigationBarHeight)
        self.bodyScrollview.bounces = true
        self.bodyScrollview.showsVerticalScrollIndicator = false
        self.view.addSubview(self.bodyScrollview)
        
        self.introLabel.textColor = .black
        self.introLabel.text = ""
        self.introLabel.font = .PingFangSC_Regular(size: 13)
        self.introLabel.numberOfLines = 0
        
        self.requestData()
        
        self.view.bringSubviewToFront(self.ac_navigationBar)
    }
    
    func requestData()  {
        guard let path = Bundle.main.path(forResource: "actor_id_\(self.actorId)", ofType: "json") else { self.profile = nil
            return
        }
        guard let jsonObject = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) else {
            self.profile = nil
            return
        }
        
        let json = JSON(jsonObject)
        self.profile = VoiceActorProfile.init(with: json)
        
        let x : CGFloat = 20
        var y : CGFloat = 0
        
        self.gridview = GridTableview.init(.zero, titleArray: self.profile!.titleArray(), contentsArray: self.profile!.contentArray())
        self.gridview!.titleColumnWidthRatio = screenWidth > 375 ? 0.3 : 0.4
        self.gridview?.hideBorderLine = true
        self.setViewWithEffectView(self.gridview!, frame: .init(x: x, y: y, width: self.view.width - 2 * x, height: self.gridview!.estimatedHeight()), inset: .init(top: 0, left: 8, bottom: 0, right: 8))
        
        y += self.gridview!.estimatedHeight()
        y += 15
        
        self.introLabel.text = self.profile!.introduction
        var labelH = (self.profile!.introduction as NSString).boundingRect(with: .init(width: self.view.width - 2 * x - 16, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : self.introLabel.font as Any], context: nil).height + 16
        labelH = ceil(labelH)
        self.setViewWithEffectView(self.introLabel, frame: .init(x: x, y: y, width: self.view.width - 2 * x, height: labelH), inset: .init(top: 8, left: 8, bottom: 8, right: 8))
        
        y += labelH
        y += 10
        
        self.bodyScrollview.contentSize = .init(width: self.view.width, height: max(y, screenHeight - statusBarHeight - navigationBarHeight + 1))
        
        self.backImageView.sd_setImage(with: URL.init(string: self.profile!.imgURL)!, completed: nil)
    }
    
    func setViewWithEffectView(_ view : UIView, frame : CGRect, inset : UIEdgeInsets) {
        let visualEffectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        visualEffectView.frame = frame
        visualEffectView.cornerRadius = 20
        visualEffectView.clipsToBounds = true
        self.bodyScrollview.addSubview(visualEffectView)
        
        visualEffectView.contentView.addSubview(view)
        
        let x = inset.left
        let y = inset.top
        view.frame = .init(x: x, y: y, width: frame.width - inset.left - inset.right, height: frame.height - inset.top - inset.bottom)
    }
}
