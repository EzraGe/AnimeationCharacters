//
//  AnimeStoryDetailController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/7/30.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class AnimeStoryDetailController : BaseController, UITableViewDataSource, UITableViewDelegate {
    
    private var backImageView = UIImageView()
    private var effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
    private var postView = UIImageView()
    private var nameLabel = UILabel()
    private var showTimeLabel = UILabel()
    private var typeLabel = UILabel()
    private var scoreLabel = UILabel()
    private var storyLabel = UILabel()
    
    private var bodyScrollview = UIScrollView()
    
    private var introductionLabel = UILabel()
    private var titleView = UILabel()
    private var gridTableview : GridTableview?
    private var tableview = UITableView()
    
    private var scrollviewContentOffsetY : CGFloat = 0
    private var tableviewContentOffsetYWhenDragBegin : CGFloat = 0
    private var offsetOftableviewContentOffsetYWhenDragging : CGFloat = 0
    
    var heightOfContentOutsideTableview : CGFloat = 0
    
    private var storyId : Int = 0
    private var profile : AnimeStoryProfile?
    
    var previous_contentOffset : CGPoint = .zero
    
    init(with storyId : Int) {
        super.init(nibName: nil, bundle: nil)
        self.storyId = storyId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.previous_contentOffset = self.bodyScrollview.contentOffset
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.bodyScrollview.contentOffset = self.previous_contentOffset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ac_navigationBarHidden = false
        self.ac_navigationBarBackButtonStyle = .black
        
        self.backImageView.frame = self.view.bounds
        self.backImageView.clipsToBounds = true
        self.view.addSubview(self.backImageView)
        
        let backWrapperView = UIImageView()
        backWrapperView.frame = self.view.bounds
        backWrapperView.image = UIImage.imageWithColor(UIColor.Social.twitter.withAlphaComponent(0.4))
        self.view.addSubview(backWrapperView)
        
        self.effectView.frame = self.view.bounds
        self.view.addSubview(self.effectView)
        
        self.bodyScrollview.frame = CGRect.init(x: 0, y: navigationBarHeight + statusBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - navigationBarHeight - statusBarHeight)
        self.bodyScrollview.isScrollEnabled = false
        self.bodyScrollview.delegate = self
        self.view.addSubview(self.bodyScrollview)
        
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(onPan(_:)))
        self.bodyScrollview.addGestureRecognizer(panGestureRecognizer)
        
        let postW = CGFloat(110)
        let postH = postW * 1.6
        let paddingPost = CGFloat(20)
        self.postView.contentMode = .scaleAspectFill
        self.postView.frame = .init(x: paddingPost, y: 0, width: postW, height: postH)
        self.bodyScrollview.addSubview(self.postView)
        heightOfContentOutsideTableview += postH
        
        let introTitleH : CGFloat = 30
        self.introductionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.introductionLabel.textColor = UIColor.Theme.black333333
        self.introductionLabel.frame = .init(x: paddingPost, y: self.postView.frame.maxY + 10, width: self.view.width - 2 * paddingPost, height: introTitleH)
        self.introductionLabel.text = "Introduction"
        self.bodyScrollview.addSubview(self.introductionLabel)
        heightOfContentOutsideTableview += (introTitleH + 10)
        
        let labelPadding = CGFloat(15)
        let rightViewsX = labelPadding + self.postView.frame.maxX
        let rightViewsW = self.view.width - labelPadding - self.postView.frame.maxX - paddingPost
        
        self.nameLabel.textColor = UIColor.Theme.black333333
        self.nameLabel.font = UIFont.PingFangSC_Regular(size: 17)
        self.nameLabel.frame = .init(x: rightViewsX, y: self.postView.frame.minY, width: rightViewsW, height: 30)
        self.bodyScrollview.addSubview(self.nameLabel)
        
        self.typeLabel.textColor = UIColor.Theme.black333333
        self.typeLabel.font = UIFont.PingFangSC_Regular(size: 15)
        self.typeLabel.frame = .init(x: rightViewsX, y: self.nameLabel.frame.maxY + 15, width: rightViewsW, height: 24)
        self.bodyScrollview.addSubview(self.typeLabel)
        
        self.showTimeLabel.textColor = UIColor.Theme.black333333
        self.showTimeLabel.font = UIFont.PingFangSC_Regular(size: 15)
        self.showTimeLabel.frame = .init(x: rightViewsX, y: self.typeLabel.frame.maxY + 15, width: rightViewsW, height: 24)
        self.bodyScrollview.addSubview(self.showTimeLabel)
        
        self.scoreLabel.textColor = UIColor.Theme.black333333
        self.scoreLabel.font = UIFont.PingFangSC_Regular(size: 15)
        self.scoreLabel.frame = .init(x: rightViewsX, y: self.showTimeLabel.frame.maxY + 15, width: rightViewsW, height: 24)
        self.bodyScrollview.addSubview(self.scoreLabel)
        
        let postPaddingBottom = CGFloat(20)
        heightOfContentOutsideTableview += postPaddingBottom
        self.storyLabel.frame = CGRect.init(x: 30, y: self.introductionLabel.frame.maxY + postPaddingBottom, width: self.view.bounds.width - 60, height: 0)
        self.storyLabel.numberOfLines = 0
        self.storyLabel.lineBreakMode = .byWordWrapping
        self.bodyScrollview.addSubview(self.storyLabel)
        
        self.titleView.textColor = UIColor.Theme.black333333
        self.titleView.textAlignment = .center
        self.titleView.font = UIFont.boldSystemFont(ofSize: 24)
        self.titleView.backgroundColor = .clear
        self.titleView.text = "Cast"
        self.bodyScrollview.addSubview(self.titleView)
        
        self.tableview.backgroundColor = .clear
        self.tableview.register(AnimeStoryDetailCastCell.self, forCellReuseIdentifier: AnimeStoryDetailCastCell.cellReuseIdentifier)
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.bounces = true
        self.tableview.showsVerticalScrollIndicator = false
        self.tableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableview.contentOffset = .init(x: 0, y: 1)
        self.bodyScrollview.addSubview(self.tableview)
        
        if #available(iOS 11.0, *) {
            self.bodyScrollview.contentInsetAdjustmentBehavior = .never
            self.tableview.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.requestData()
        
        self.view.bringSubviewToFront(self.ac_navigationBar)
    }
    
    private func requestData()  {
        guard let path = Bundle.main.path(forResource: "story_id_\(self.storyId)", ofType: "json") else { self.profile = nil
            return
        }
        guard let jsonObject = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) else {
            self.profile = nil
            return
        }
        
        let json = JSON(jsonObject)
        self.profile = AnimeStoryProfile.init(with: json)
        
        self.backImageView.sd_setImage(with: URL.init(string: self.profile!.imgURL)!, completed: nil)
        self.postView.sd_setImage(with: URL.init(string: self.profile!.imgURL)!, completed: nil)
        self.nameLabel.text = self.profile!.name
//        var tag = self.profile!.typeTags.reduce("Type : ") {$0 + "、" + $1}
//        self.typeLabel.text = tag.slice(at: 1)
        self.typeLabel.text = "Type : " + (self.profile!.typeTags as NSArray).componentsJoined(by: ", ")
        self.showTimeLabel.text = "Released : " + self.profile!.firstShowTime
        self.scoreLabel.text = "score : \(self.profile!.score)"
        
        let introduction = self.profile!.introduction
        var storyH = (introduction as NSString).boundingRect(with: .init(width: self.view.width - 60, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: ([NSAttributedString.Key.font : self.storyLabel.font] as Any as! [NSAttributedString.Key : Any]), context: nil).height
        storyH = ceil(storyH)
        self.storyLabel.height = storyH
        self.storyLabel.text = introduction
        heightOfContentOutsideTableview += self.storyLabel.height
        
        self.titleView.frame = CGRect.init(x: 0, y: self.storyLabel.frame.maxY, width: self.view.bounds.width, height: 60)
        self.tableview.frame = CGRect.init(x: 0, y: self.titleView.frame.maxY, width: self.view.bounds.width, height: self.view.frame.height - statusBarHeight - navigationBarHeight - titleView.height)
//        self.tableview.reloadSections([0], with: .fade)
        self.tableview.reloadSections([0], with: .fade)
        
        let h = self.tableview.contentSize.height + self.titleView.frame.height + self.storyLabel.frame.height
        self.bodyScrollview.contentSize = .init(width: 0, height: h)
    }
    
    //MARK: Gesture
    
    @objc func onPan(_ panGestureRecognizer : UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            self.scrollviewContentOffsetY = self.bodyScrollview.contentOffset.y
            
        case .changed:
            fallthrough
        case .cancelled:
            let translation = panGestureRecognizer.translation(in: self.view)
            if abs(translation.y) > 0 {
                var y = min(self.scrollviewContentOffsetY - translation.y, heightOfContentOutsideTableview)
                y = max(0, y)
                self.bodyScrollview.contentOffset = CGPoint.init(x: self.bodyScrollview.contentOffset.x, y: y)
            }
        default:
            break
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.isEqual(self.tableview) {
            self.tableviewContentOffsetYWhenDragBegin = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(self.tableview) {
            if scrollView.isDragging {
                self.offsetOftableviewContentOffsetYWhenDragging = scrollView.contentOffset.y - self.tableviewContentOffsetYWhenDragBegin
                
                if ((self.tableview.contentOffset.y < 0 && self.bodyScrollview.contentOffset.y <= 0) || (self.offsetOftableviewContentOffsetYWhenDragging < 0 && self.tableview.contentOffset.y > 0)) {
                    
                } else {
                    let y = max(0, min(heightOfContentOutsideTableview, self.bodyScrollview.contentOffset.y + self.offsetOftableviewContentOffsetYWhenDragging))
                    self.bodyScrollview.contentOffset = CGPoint.init(x: self.bodyScrollview.contentOffset.x, y: y)
                    
                    if self.bodyScrollview.contentOffset.y < heightOfContentOutsideTableview && self.bodyScrollview.contentOffset.y > 0 {
                        self.tableview.contentOffset = .init(x: self.tableview.contentOffset.x, y: max(0, self.tableviewContentOffsetYWhenDragBegin))
                    }
                }
                
                self.tableviewContentOffsetYWhenDragBegin = self.tableview.contentOffset.y
            }
        }
    }
    
    // MARK: UITableView DataSource && Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profile?.cast.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.profile?.cast[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: AnimeStoryDetailCastCell.cellReuseIdentifier, for: indexPath)
        cell.updateWith(data: data as AnyObject?, indexPath: indexPath)
        let detailCell = cell as! AnimeStoryDetailCastCell
        weak var weakSelf = self
        
        detailCell.clickCharacterAvatorViewHandler = { (id : Int) in
            let characterDetailController = CharacterDetailController.init(with: id)
           
            guard let _ = Bundle.main.path(forResource: "character_id_\(id)", ofType: "json") else {
                weakSelf?.navigationController?.pushViewController(ErrorController(), animated: true)
                return
            }
            weakSelf?.navigationController?.pushViewController(characterDetailController, animated: true)
        }
        detailCell.clickVoiceActorAvatorViewHandler = { (id : Int) in
            let voiceActorDetailController = VoiceActorDetailController.init(with: id)
            
            guard let _ = Bundle.main.path(forResource: "actor_id_\(id)", ofType: "json") else {
                weakSelf?.navigationController?.pushViewController(ErrorController(), animated: true)
                return
            }
            weakSelf?.navigationController?.pushViewController(voiceActorDetailController, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AnimeStoryDetailCastCell.cellHeight(for: nil)
    }
}
