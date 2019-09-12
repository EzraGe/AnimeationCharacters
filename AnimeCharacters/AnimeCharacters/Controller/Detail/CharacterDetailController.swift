//
//  CharacterDetailController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/30.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class CharacterDetailController: BaseController , UITableViewDataSource, UITableViewDelegate{
    
    private var characterId : Int = 0
    
    private var backImageView = UIImageView()
    private var effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
    
    private var bodyScrollview = UIScrollView()
    private var characterImageview = UIImageView()
    private var gridview : GridTableview?
    private var introLabel = UILabel()
    private var lineList = UITableView()
    
    private var profile : CharacterProfile?
    
    init(with characterId : Int) {
        super.init(nibName: nil, bundle: nil)
        self.characterId = characterId
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
        self.view.addSubview(self.backImageView)
        
        self.bodyScrollview.frame = .init(x: 0, y: statusBarHeight + navigationBarHeight, width: self.view.width, height: self.view.height - statusBarHeight - navigationBarHeight)
        self.view.addSubview(self.bodyScrollview)
        
        self.introLabel.textColor = .black
        self.introLabel.text = ""
        self.introLabel.font = .PingFangSC_Regular(size: 13)
        self.introLabel.numberOfLines = 0
        
        self.lineList.backgroundColor = .clear
        self.lineList.register(LineCell.self, forCellReuseIdentifier: LineCell.cellReuseIdentifier)
        self.lineList.dataSource = self
        self.lineList.delegate = self
        self.lineList.isScrollEnabled = false
        self.lineList.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        self.requestData()
        
        self.view.bringSubviewToFront(self.ac_navigationBar)
    }
    
    func requestData()  {
        guard let path = Bundle.main.path(forResource: "character_id_\(self.characterId)", ofType: "json") else { self.profile = nil
            return
        }
        guard let jsonObject = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) else {
            self.profile = nil
            return
        }
        
        let json = JSON(jsonObject)
        self.profile = CharacterProfile.init(with: json)
        
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
        
        self.setViewWithEffectView(self.lineList, frame: .init(x: x, y: y, width: self.view.width - 2 * x, height: CGFloat(self.profile!.lines.count) * LineCell.cellHeight(for: nil) + 40), inset: .zero)
        self.lineList.reloadSectionsWithUpdates([0], with: .fade)
        y += self.lineList.height
        
        self.bodyScrollview.contentSize = .init(width: self.view.width, height: y)
        
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let wapperView = UIView.init(frame: .init(x: 0, y: 0, width: tableView.width, height: 40))
        let label = UILabel()
        label.frame = .init(x: 15, y: 0, width: tableView.width - 40, height: 30)
        label.textColor = UIColor.Theme.black333333
        label.font = .boldSystemFont(ofSize: 22)
        label.text = "Line List"
        wapperView.addSubview(label)
        return wapperView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profile!.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LineCell.cellReuseIdentifier, for: indexPath)
        let line = self.profile!.lines[indexPath.row]
        (cell as! LineCell).updateWith(data: line as AnyObject, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LineCell.cellHeight(for: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        Player.player.setupList(self.profile!.lines, currentIndex: indexPath.row)
        
        let line = self.profile!.lines[indexPath.row]
        let playController = VoicePlayerController.init(line: line)
        self.navigationController?.pushViewController(playController, animated: true)
    }
}
