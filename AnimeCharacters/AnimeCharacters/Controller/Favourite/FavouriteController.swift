//
//  FavouriteController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/3.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit
import SnapKit

enum CollectionType : Int, Codable {
    case Story
    case Character
    case VoiceActor
    case Line
}

protocol CollectionModel : Codable {
    var collectionType : CollectionType { get }
//    var isFavourited : Bool { get set }
}

enum PersistentObject : Codable, Equatable {
    case character(Character)
    case animeStory(AnimeStory)
    case voiceActor(VoiceActor)
    case lineModel(LineModel)
    
    private enum CodingKeys : String, CodingKey {
        case character, animeStory, voiceActor, lineModel
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .character(let value):
            try container.encode(value, forKey: .character)
        case .animeStory(let value):
            try container.encode(value, forKey: .animeStory)
        case .voiceActor(let value):
            try container.encode(value, forKey: .voiceActor)
        case .lineModel(let value):
            try container.encode(value, forKey: .lineModel)
        }
    }
    
    init(c : Character) {
        self = .character(c)
    }
    
    init(story : AnimeStory) {
        self = .animeStory(story)
    }
    
    init(va : VoiceActor) {
        self = .voiceActor(va)
    }
    
    init(line : LineModel) {
        self = .lineModel(line)
    }
    
    init(data : FeedListModel) {
        if type(of: data) == AnimeStory.self {
            let story = data as! AnimeStory
            self = .init(story: story)
        } else if type(of: data) == Character.self {
            let chracter = data as! Character
            self = .init(c: chracter)
        } else {
            let va = data as! VoiceActor
            self = .init(va: va)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self = .character(try container.decode(Character.self, forKey: .character))
        } catch DecodingError.keyNotFound {
            do {
                self = .animeStory(try container.decode(AnimeStory.self, forKey: .animeStory))
            } catch DecodingError.keyNotFound {
                do {
                    self = .voiceActor(try container.decode(VoiceActor.self, forKey: .voiceActor))
                } catch DecodingError.keyNotFound {
                    self = .lineModel(try container.decode(LineModel.self, forKey: .lineModel))
                }
            }
        }
    }
}

protocol DropDownViewDelegate : NSObject {
    func didSelect(dropDownView : DropDownView, index : Int)
}

enum DropDownOption {
    case all
    case story
    case character
    case voiceActor
    case line
}

var dropDownBtnTagBase : Int = 30000

class DropDownView : UIView {
    
    weak var delegate : DropDownViewDelegate?
    
    var option : DropDownOption = .all
    
    var isExpanded : Bool = false {
        willSet {
            if newValue == true {
                self.show()
            } else {
                self.hide({})
            }
        }
    }
    
    private var optionTitles : [String] = []
    private var btns : [UIButton] = []
    private var btnsWapperView = UIView()
    
    static let dropDownBtnHeight : CGFloat = 44
    
    init(frame: CGRect, optionTitles : [String] ) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.optionTitles = optionTitles
        let count = self.optionTitles.count
        
        self.btnsWapperView.backgroundColor = UIColor.Social.twitter.withAlphaComponent(0.8)
        self.btnsWapperView.isHidden = true
        
        for i in 0..<count {
            let optionName = self.optionTitles[i]
            let btn = UIButton()
            btn.tag = i + dropDownBtnTagBase
            btn.titleLabel?.textColor = UIColor.Social.facebook
            btn.titleLabel?.font = UIFont.PingFangSC_Regular(size: 18)
            btn.setTitle(optionName, for: UIControl.State.normal)
            self.btnsWapperView.addSubview(btn)
            self.btns.append(btn)
            btn.addTarget(self, action: #selector(onOptionBtnClick(_:)), for: .touchUpInside)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onOptionBtnClick(_ btn : UIButton) {
        let index = btn.tag - dropDownBtnTagBase
        switch index {
        case 0:
            self.option = .all
        case 1:
            self.option = .story
        case 2:
            self.option = .character
        case 3:
            self.option = .voiceActor
        case 4:
            self.option = .line
        default:break
        }
        isExpanded = false
        self.delegate?.didSelect(dropDownView: self, index: index)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let count = self.optionTitles.count
        self.btnsWapperView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: CGFloat(count) * DropDownView.dropDownBtnHeight)
        
        var y = CGFloat(0)
        for i in 0..<count {
            let btn = self.btns[i]
            btn.frame = CGRect.init(x: 0, y: y, width: self.bounds.width, height: DropDownView.dropDownBtnHeight)
            y += DropDownView.dropDownBtnHeight
        }
    }
    
    func show() {
        self.btnsWapperView.isHidden = false
        self.addSubview(self.btnsWapperView)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.9,
            options: [],
            animations: {
                self.btnsWapperView.frame.origin.y = 0
                self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: DropDownView.dropDownBtnHeight * CGFloat(self.optionTitles.count))
        }) { (_) in
            
        }
    }
    
    func hide(_ completion : @escaping () -> ()) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.9,
            options: [],
            animations: {
                self.frame = CGRect.init(x: 0, y: self.frame.origin.y, width: self.frame.width, height: 0)
        }) { (_) in
            completion()
        }
    }
}

class FavouriteCellTag : UILabel {
    var textWidth : CGFloat = 0
    var type : CollectionType {
        didSet {
            switch self.type {
            case .Story:
                self.text = "story"
                self.backgroundColor = UIColor.FlatUI.amethyst
            case .Character:
                self.text = "character"
                self.backgroundColor = UIColor.FlatUI.carrot
            case .VoiceActor:
                self.text = "voice actor"
                self.backgroundColor = UIColor.FlatUI.pumkin
            case .Line:
                self.text = "line"
                self.backgroundColor = UIColor.FlatUI.greenSea
            }
            self.textWidth = ceil((self.text! as NSString).boundingRect(with: .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : self.font as Any], context: nil).width)
        }
    }
    
    override init(frame: CGRect) {
        type = .Story
        super.init(frame: frame)
        self.font = UIFont.PingFangSC_Regular(size: 12)
        self.textColor = UIColor.white
        self.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FavouriteCollectionCell : UITableViewCell {
    var data : Any?
    
    private var avatorView = UIImageView()
    private var nameLabel = UILabel()
    private var tagView = FavouriteCellTag()
    
    override func updateWith(data: AnyObject?, indexPath: IndexPath) {
        super.updateWith(data: data, indexPath: indexPath)
        
        var urlStr : String
        var name : String
        if (data != nil) {
            let dataCore = data as! CollectionModel
            if type(of: dataCore) == AnimeStory.self {
                let story : AnimeStory = dataCore as! AnimeStory
                self.data = story
                urlStr = story.backImageURL
                name = story.name
                self.tagView.type = .Story
            } else if type(of: dataCore) == VoiceActor.self {
                let va : VoiceActor = dataCore as! VoiceActor
                self.data = va
                urlStr = va.avator
                name = va.name
                self.tagView.type = .VoiceActor
            } else {
                let character : Character = dataCore as! Character
                self.data = character
                urlStr = character.avator
                name = character.name
                self.tagView.type = .Character
            }
        } else {
            urlStr = ""
            name = ""
        }
        
        self.avatorView.sd_setImage(with: URL.init(string: urlStr), completed: nil)
        self.nameLabel.text = name
        self.tagView.snp.updateConstraints { (_ make : ConstraintMaker) in
            make.width.equalTo(self.tagView.textWidth + 10)
        }
        self.tagView.cornerRadius = 5
        self.tagView.clipsToBounds = true
    }
    
    override class func cellHeight(for data : Any?) -> CGFloat {
        return 84
    }
    
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
        let square : CGFloat = 54
        let padding : CGFloat = 15
        let v_padding : CGFloat = (type(of: self).cellHeight(for: nil) - square) * 0.5
        self.avatorView.contentMode = .scaleAspectFill
        self.avatorView.cornerRadius = 0.5 * square
        self.avatorView.clipsToBounds = true
        self.contentView.addSubview(self.avatorView)
        self.avatorView.snp.remakeConstraints { (_ make: ConstraintMaker) in
            make.left.equalToSuperview().offset(padding)
            make.width.height.equalTo(square)
            make.top.equalToSuperview().offset(v_padding)
        }
        
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.nameLabel.textColor = UIColor.Theme.black333333
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.remakeConstraints { (_ make : ConstraintMaker) in
            make.left.equalTo(self.avatorView.snp.right).offset(10)
            make.top.equalTo(self.avatorView).offset(5)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-padding)
        }
        
        self.contentView.addSubview(self.tagView)
        self.tagView.snp.makeConstraints { (_ make : ConstraintMaker) in
            make.left.equalTo(self.nameLabel)
            make.bottom.equalTo(self.avatorView.snp.bottom).offset(-5)
            make.height.equalTo(20)
            make.width.equalTo(0)
        }
    }
}

class FavouriteController : BaseController, DropDownViewDelegate , UITableViewDataSource, UITableViewDelegate {
    
    private var filterButton = UIButton()
    private var list = UITableView()
    private var dropDownView = DropDownView.init(frame: .zero, optionTitles: ["All", "Story", "Character", "VoiceActor", "Line"])
    private var dataSource : [CollectionModel] = Favourites.sharedInstance.allCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ac_navigationBarHidden = false
        self.ac_navigationBarBackButtonStyle = .clear
        self.ac_navigationBar.titleLabel.text = "Favourite"
        
        self.view.addSubview(self.filterButton)
        let btnSquare : CGFloat = 44
        self.filterButton.center = CGPoint.init(x: 0.5 * btnSquare, y: self.ac_navigationBar.center.y)
        self.filterButton.bounds = CGRect.init(x: 0, y: 0, width: btnSquare, height: btnSquare)
        self.filterButton.setImage(UIImage.init(named: "favourite_filter"), for: UIControl.State.normal)
        self.filterButton.addTarget(self, action: #selector(onFilterButtonClick), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(self.list)
        self.list.frame = CGRect.init(x: 0, y: statusBarHeight + navigationBarHeight, width: screenWidth, height: screenHeight - statusBarHeight - navigationBarHeight - bottomSafeAreaHeight - 49)
        self.list.register(FavouriteCollectionCell.self, forCellReuseIdentifier: FavouriteCollectionCell.cellReuseIdentifier)
        self.list.register(LineCell.self, forCellReuseIdentifier: LineCell.cellReuseIdentifier)
        self.list.dataSource = self
        self.list.delegate = self
        self.list.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.list.showsVerticalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            self.list.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.dropDownView.frame = CGRect.init(x: 0, y: self.ac_navigationBar.frame.maxY, width: screenWidth, height: 20)
        self.dropDownView.delegate = self
        self.view.addSubview(self.dropDownView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ds = Favourites.sharedInstance.currentDataSource(self.dropDownView.option)
        if ds.count != self.dataSource.count {
            self.dataSource = ds
            self.list.reloadSectionsWithUpdates([0], with: .fade)
        }
    }
    
    @objc func onFilterButtonClick() {
        self.dropDownView.isExpanded = !self.dropDownView.isExpanded
    }
    
    func didSelect(dropDownView: DropDownView, index: Int) {
        let favourites = Favourites.sharedInstance
        switch dropDownView.option {
        case .story:
            self.dataSource = favourites.storyCollection()
        case .character:
            self.dataSource = favourites.characterCollection()
        case .voiceActor:
            self.dataSource = favourites.voiceActorCollection()
        case .line:
            self.dataSource = favourites.lineCollection()
        case .all:
            fallthrough
        default:
            self.dataSource = favourites.allCollection()
        }
        self.list.reloadSectionsWithUpdates([0], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Favourites.sharedInstance.numberOfRows(self.dropDownView.option)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.dataSource[indexPath.row]
        var identifier = ""
        
        switch data.collectionType {
        case .Line:
            identifier = "\(LineCell.self)"
        default:
            identifier = "\(FavouriteCollectionCell.self)"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if data.collectionType == .Line {
            (cell as! LineCell).showLineTag = true
        }
        cell.updateWith(data: data as AnyObject, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let data = self.dataSource[indexPath.row]
        var controller : UIViewController
        
        weak var weakself = self
        switch data.collectionType {
        case .Story:
            let story = data as! AnimeStory
            guard let _ = Bundle.main.path(forResource: "story_id_\(story.id)", ofType: "json") else {
                weakself?.navigationController?.pushViewController(ErrorController(), animated: true)
                return
            }
            controller = AnimeStoryDetailController.init(with: story.id)
        case .Character:
            let cha = data as! Character
            guard let _ = Bundle.main.path(forResource: "character_id_\(cha.id)", ofType: "json") else {
                weakself?.navigationController?.pushViewController(ErrorController(), animated: true)
                return
            }
            controller = CharacterDetailController.init(with: cha.id)
        case .VoiceActor:
            let actor = data as! VoiceActor
            guard let _ = Bundle.main.path(forResource: "actor_id_\(actor.id)", ofType: "json") else {
                weakself?.navigationController?.pushViewController(ErrorController(), animated: true)
                return
            }
            controller = VoiceActorDetailController.init(with: actor.id)
        case .Line:
            let line = data as! LineModel
            let lines = Favourites.sharedInstance.lineCollection() as! [LineModel]
            var idx = lines.indexOf(line) { (this, other) -> (Bool) in
                return this.id == other.id
            }
            if idx == ArrayElementNotFound {
                idx = 0
            }
            Player.player.setupList(lines, currentIndex: idx)
            controller = VoicePlayerController.init(line: line)
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.dataSource[indexPath.row]
        switch data.collectionType {
        case .Line:
            return LineCell.cellHeight(for: data)
        default:
            return FavouriteCollectionCell.cellHeight(for: data)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let data : CollectionModel = self.dataSource[indexPath.row]
            Favourites.sharedInstance.unpersist(data) { (success) in
                if success {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CancelFavouriteNotification), object: nil, userInfo: ["data" : data])
                    self.dataSource = Favourites.sharedInstance.currentDataSource(self.dropDownView.option)
                    self.list.reloadSectionsWithUpdates([0], with: .fade)
                }
            }
        }
    }
}
