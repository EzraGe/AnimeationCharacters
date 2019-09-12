//
//  AnimeTabbar.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/31.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SnapKit

let tabBarButtonTag = 20000

enum Language {
    case SimplfiedChinese
    case TraditionalChinese
    case English
    case Japanese
}

class TabBarItem {
    var tabName : String
    var tabImageName : String
    
    init() {
        self.tabName = ""
        self.tabImageName = ""
    }
    
    func updateName(language : Language, tabIndex : Int) {
        var name = ""
        
        switch language {
        case .SimplfiedChinese:
            if tabIndex == 0 {
                name = "推荐"
            } else {
                name = "收藏"
            }
            
        case .TraditionalChinese:
            if tabIndex == 0 {
                name = "推薦"
            }  else {
                name = "收藏"
            }
            
        case .Japanese :
            if tabIndex == 0 {
                name = "推薦"
            } else {
                name = "大好き"
            }
            
        case .English :
            fallthrough
        default:
            if tabIndex == 0 {
                name = "feed"
            } else {
                name = "favourite"
            }
        }
        
        self.tabName = name
    }
}

class AnimeTabBarButton : UIButton {
    
    override var isSelected : Bool {
        set {
            super.isSelected = newValue
            self.layoutSubviews()
        }
        get {
            return super.isSelected
        }
    }
    
    static let originCornorRadius : CGFloat = 16
    static let expandedCornorRadius : CGFloat = 24
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return self.isSelected ? CGRect.zero : CGRect.init(x: 0, y: 32 + 1, width: contentRect.size.width, height: 16)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let square = CGFloat(32)
        let x = (contentRect.size.width - square) * 0.5
        let expandedSquare = CGFloat(48)
        let expandedX = (contentRect.size.width - expandedSquare) * 0.5
        return self.isSelected ? CGRect.init(x: expandedX, y: 0, width: expandedSquare, height: expandedSquare) : CGRect.init(x: x, y: 0, width: square, height: square)
    }
}

protocol AnimeTabBarDelegate : NSObjectProtocol {
    func tabBar(_ tabBar : AnimeTabBar, didSelect item : TabBarItem, at index : Int)
}

class AnimeTabBar : UIView {
    
    weak var animeTabBarDelegate : AnimeTabBarDelegate?
    
    private var effectView = UIVisualEffectView.init()
    
    var tabBarItems : Array<TabBarItem> = Array<TabBarItem>() {
        didSet {
            self.reload()
        }
    }
    
    var tabBarButtons : Array<AnimeTabBarButton> = Array<AnimeTabBarButton>()
    
    func reload() {
        for subview in self.subviews {
            if type(of: subview) == AnimeTabBarButton.self {
                subview.removeFromSuperview()
            }
        }
        
        let numberOfButtons = self.tabBarItems.count
        let space : CGFloat = (screenWidth - CGFloat(49 * numberOfButtons)) / CGFloat((numberOfButtons + 1))
        var x : CGFloat = space
        for i in 0..<numberOfButtons {
            let btn = AnimeTabBarButton()
            self.effectView.contentView.addSubview(btn)
            btn.snp.remakeConstraints { (_ make : ConstraintMaker) in
                make.left.equalToSuperview().offset(x)
                make.width.height.equalTo(49)
                make.top.equalToSuperview()
            }
            x += 49
            x += space
            
            btn.tag = tabBarButtonTag + i
            btn.addTarget(self,
                          action: #selector(tabbatButtonDidClick(sender:)),
                          for: UIControl.Event.touchUpInside)
            self.tabBarButtons.append(btn)
            
            let item : TabBarItem = self.tabBarItems[i]
            btn.setImage(UIImage.init(named: item.tabImageName), for: UIControl.State.normal)
            btn.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            btn.imageView?.cornerRadius = 16
            btn.imageView?.clipsToBounds = true
            
            btn.titleLabel?.textAlignment = NSTextAlignment.center
            btn.titleLabel?.font = UIFont.PingFangSC_Regular(size: 11)
            btn.setTitle(item.tabName, for: UIControl.State.normal)
            btn.setTitleColor(UIColor.Theme.black333333, for: UIControl.State.normal)
        }
    }
    
    @objc func tabbatButtonDidClick(sender : AnimeTabBarButton) {
        let index = sender.tag - tabBarButtonTag
        let item = self.tabBarItems[index]
        self.select(at: index)
        self.animeTabBarDelegate?.tabBar(self, didSelect: item, at: index)
    }
    
    func select(at index : Int) {
        if index < 0 || index >= self.tabBarButtons.count {
            return
        }
        
        let btnToSelect = self.tabBarButtons[index]
        for view in self.effectView.contentView.subviews {
            if type(of: view) == AnimeTabBarButton.self {
                let btn = view as! AnimeTabBarButton
                btn.isSelected = false
                btn.imageView?.cornerRadius = AnimeTabBarButton.originCornorRadius
                
                if btn == btnToSelect {
                    UIView.animate(withDuration: 0.2) {
                        btn.isSelected = true
                        btn.imageView?.cornerRadius = AnimeTabBarButton.expandedCornorRadius
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.Social.twitter
        self.effectView.effect = UIBlurEffect.init(style: .light)
        self.addSubview(self.effectView)
        self.effectView.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
