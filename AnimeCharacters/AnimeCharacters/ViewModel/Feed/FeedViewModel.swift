//
//  FeedViewModel.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/5.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

protocol FeedListModel {
    var cellType : String { get }
}

protocol FeedListCellProtocol {
    func update(with data : FeedListModel, at indexPath : IndexPath)
}

class FeedListBaseCell : UITableViewCell, FeedListCellProtocol {
    func update(with data: FeedListModel, at indexPath: IndexPath) { }
    class func cellHeight(for data: FeedListModel) -> CGFloat { return 0 }
    
    var detailContentView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.detailContentView.backgroundColor = UIColor.Social.twitter
        self.detailContentView.cornerRadius = 10
        self.detailContentView.clipsToBounds = true
        
        self.contentView.addSubview(self.detailContentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h_space : CGFloat = 20
        let v_space : CGFloat = 15
        self.detailContentView.frame = .init(x: h_space, y: v_space, width: self.width - 2 * h_space, height: self.height - 2 * v_space)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeedViewModel {
    var feedModelList : Array<FeedListModel> = Array<FeedListModel>()
    
    weak var controller : FeedController?
    
    func numberOfRows() -> Int {
        return self.feedModelList.count
    }
    
    func cellForRow(at indexPath : IndexPath) -> UITableViewCell? {
        let tableview = self.controller?.feedList
        
        if tableview != nil {
            let listModel : FeedListModel = self.feedModelList[indexPath.row]
            let cell : FeedListBaseCell  = tableview!.dequeueReusableCell(withIdentifier: listModel.cellType, for: indexPath) as! FeedListBaseCell
            cell.update(with: listModel, at: indexPath)
            if type(of: cell) == ADCell.self {
                let adCell = cell as! ADCell
                weak var weakSelf = self
                adCell.removeCallback = {
                    weakSelf?.feedModelList.remove(at: indexPath.row)
                    weakSelf?.controller?.feedList.deleteRows(at: [indexPath], with: .automatic)
                }
            } else {
                var favouriteCell = cell as! FavouriteCell
                let needUpdate = Favourites.sharedInstance.isFavourited(data: listModel)
                
                //data.isFavourited = needUpdate
                favouriteCell.favourBtn.isSelected = needUpdate
                favouriteCell.like = { (data) in
                    Favourites.sharedInstance.persist(data, completion: { (success) in
                        if success {
                            favouriteCell.favourBtn.isSelected = true
                        }
                    })
                }
                favouriteCell.cancelFavourite = { (data) in
                    Favourites.sharedInstance.unpersist(data, completion: { (success) in
                        if success {
                            favouriteCell.favourBtn.isSelected = false
                        }
                    })
                }
            }
            return cell
        } else {
            return nil
        }
    }
    
    func heightForCell(at indexPath : IndexPath) -> CGFloat {
        let listModel : FeedListModel = self.feedModelList[indexPath.row]
        let classTypeName = listModel.cellType.byInsertingAppNameBefore()
        let classType = NSClassFromString(classTypeName) as! FeedListBaseCell.Type
        return classType.cellHeight(for: listModel)
    }
    
    func select(at indexPath : IndexPath) {
        let data = self.feedModelList[indexPath.row]
        var controller : UIViewController? = nil
        weak var weakself = self
        
        if type(of: data) == AnimeStory.self {
            let story = data as! AnimeStory
            guard let _ = Bundle.main.path(forResource: "story_id_\(story.id)", ofType: "json") else {
            weakself?.controller?.navigationController?.pushViewController(ErrorController(), animated: true)
                return
            }
            controller = AnimeStoryDetailController.init(with: story.id)
        } else if type(of: data) == Character.self {
            let chara = data as! Character
            guard let _ = Bundle.main.path(forResource: "character_id_\(chara.id)", ofType: "json") else {
                weakself?.controller?.navigationController?.pushViewController(ErrorController(), animated: true)
                return
            }
            controller = CharacterDetailController.init(with: chara.id)
        } else if type(of: data) == VoiceActor.self {
            let actor = data as! VoiceActor
            guard let _ = Bundle.main.path(forResource: "actor_id_\(actor.id)", ofType: "json") else {
                weakself?.controller?.navigationController?.pushViewController(ErrorController(), animated: true)
                return
            }
            controller = VoiceActorDetailController.init(with: actor.id)
        } else {
            return
        }
        
        if controller != nil {
            self.controller?.navigationController?.pushViewController(controller!, animated: true)
        }
    }
    
    func cancelFavourite(for data : CollectionModel) {
        let row = self.indexOfDataToBeUpdate(data)
        if row >= 0 {
            let indexPath = IndexPath.init(row: row, section: 0)
            self.controller?.feedList.reloadRowsWithUpdates(at: [indexPath], with: .fade)
        }
    }
    
    private func indexOfDataToBeUpdate(_ data : CollectionModel) -> Int {
        var row = -1
        switch data.collectionType {
        case .Story:
            let story = data as! AnimeStory
            row = self.feedModelList.indexOf(story, comparation: { (_ d1, _ d2) -> (Bool) in
                let story1 = d1 as! AnimeStory
                if type(of: d2) == AnimeStory.self {
                    let story2 = d2 as! AnimeStory
                    return story1 == story2
                } else {
                    return false
                }
            })
        case .Character:
            let chara = data as! Character
            row = self.feedModelList.indexOf(chara, comparation: { (_ d1, _ d2) -> (Bool) in
                let chara1 = d1 as! Character
                if type(of: d2) == Character.self {
                    let chara2 = d2 as! Character
                    return chara1 == chara2
                } else {
                    return false
                }
            })
        case .VoiceActor:
            let actor = data as! VoiceActor
            row = self.feedModelList.indexOf(actor, comparation: { (_ d1, _ d2) -> (Bool) in
                let actor1 = d1 as! VoiceActor
                if type(of: d2) == VoiceActor.self {
                    let actor2 = d2 as! VoiceActor
                    return actor1 == actor2
                } else {
                    return false
                }
            })
        default:break
        }
        return row
    }
    
    func mockData() {
        let codeGeass : AnimeStory = AnimeStory.init(id : 0, name: "コードギアス 反逆のルルーシュ", onlineTime: "2006.10", backImageURL: "http://i0.hdslb.com/bfs/article/aa5826e1566bf5dd16885234f15f1eb976cd3778.jpg")
        self.feedModelList.append(codeGeass)
        
        let l_l_avator = "http://www.005.tv/uploads/allimg/161113/6-1611131I42L00.jpg"
        let l_l = Character.init(id : 0, name: "Lelouch·vi·Britannia", avator: l_l_avator, cv : "福山潤")
        self.feedModelList.append(l_l)
        
        let c_c_avator = "http://img1.imgtn.bdimg.com/it/u=3540086911,2127876834&fm=214&gp=0.jpg"
        let c_c : Character = Character.init(id : 1, name: "C.C", avator: c_c_avator, cv: "野上 ゆかな")
        self.feedModelList.append(c_c)

        let suzaku = Character.init(id : 2, name: "枢木スザク", avator: "http://img3.duitang.com/uploads/item/201305/25/20130525225123_siMwi.thumb.700_0.jpeg", cv: "櫻井 孝宏")
        self.feedModelList.append(suzaku)
        
        let karen = Character.init(id : 3, name: "Kallen Stadtfeld", avator: "http://uploads.5068.com/allimg/111123/113F341P-4.jpg", cv: "小清水 亜美")
        self.feedModelList.append(karen)

        let fukuyamaJun = VoiceActor.init(id : 0, name: "福山 潤", avator: "http://upload.mnw.cn/2016/1221/1482283660389.jpg")
        self.feedModelList.append(fukuyamaJun)
        
        let yukana = VoiceActor.init(id : 1, name: "野上 ゆかな", avator: "http://f.hiphotos.baidu.com/baike/whfpf=683,683,0/sign=ba800228a5ec08fa265540e73fd30b55/34fae6cd7b899e5142309c8347a7d933c9950dee.jpg")
        self.feedModelList.append(yukana)
        
        let takahiro = VoiceActor.init(id : 2, name: "櫻井 孝宏", avator: "http://img2.imgtn.bdimg.com/it/u=2451295502,3792469451&fm=214&gp=0.jpg")
        self.feedModelList.append(takahiro)
        
        let ami = VoiceActor.init(id : 3, name: "小清水 亜美", avator: "http://pic.baike.soso.com/p/20130704/20130704162040-391650393.jpg")
        self.feedModelList.append(ami)
        
        let ad : ADModel = ADModel.init(name: "Kevin", description: "is looking for a job...")
        self.feedModelList.append(ad)
        
        let deathNote = AnimeStory.init(id: 1, name: "Death Note", onlineTime: "2006.10", backImageURL: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566754534218&di=a86a3159f226063bf106a464c52d49bc&imgtype=0&src=http%3A%2F%2Fimages6.fanpop.com%2Fimage%2Fphotos%2F39900000%2Fdeath-note-anime-death-note-39916428-3917-3000.jpg")
        self.feedModelList.append(deathNote)
        
        let light = Character.init(id : 4, name: "やがみ ライト", avator: "http://b-ssl.duitang.com/uploads/item/201612/08/20161208192154_TCAeE.thumb.700_0.jpeg", cv: "宮野 真守")
        self.feedModelList.append(light)
        
        let l = Character.init(id : 5, name: "L·Lawliet", avator: "http://images6.fanpop.com/image/photos/35700000/L-Lawliet-death-note-35773760-704-396.jpg", cv: "山口 勝平")
        self.feedModelList.append(l)
        
        let misa = Character.init(id : 6, name: "Misa Amane", avator: "http://img3.imgtn.bdimg.com/it/u=641205713,163626298&fm=26&gp=0.jpg", cv: "平野绫")
        self.feedModelList.append(misa)
        
        let mamo = VoiceActor.init(id : 4, name: "宮野 真守", avator: "http://i0.hdslb.com/bfs/face/fa39b11fede5997d996709b71865c637d732c3d4.jpg")
        self.feedModelList.append(mamo)
        
        let yamakuchi = VoiceActor.init(id : 5, name: "山口 勝平", avator: "http://images.17173.com/2014/news/2014/05/21/mj0521aaa06s.jpg")
        self.feedModelList.append(yamakuchi)
        
        let aya = VoiceActor.init(id : 6, name: "平野绫", avator: "http://uploads.5068.com/allimg/1801/78-1P102154344.jpg")
        self.feedModelList.append(aya)
        
        let karakaijyoutunotakakisann = AnimeStory.init(id: 2, name: "からかい上手の高木さん", onlineTime: "2008.01", backImageURL: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566755073734&di=41feee9c043586577c49a658f3086d10&imgtype=0&src=http%3A%2F%2Fi0.hdslb.com%2Fbfs%2Farticle%2F1c5c53d52af9f440c8e86acd74c86f6eb2ba2346.png")
        self.feedModelList.append(karakaijyoutunotakakisann)
        
        let takakisan = Character.init(id: 7, name: "高木さん", avator: "http://dingyue.nosdn.127.net/Cszhx0DjC7y2QzXmYhh1uI8evuLgHsRjE1iCzlu==s5we1507720353676compressflag.jpg", cv: "高橋 李依")
        self.feedModelList.append(takakisan)
        
        let nishikata = Character.init(id : 8, name: "西片", avator: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1566758167647&di=04d3e38dca42bc2deca9136cc6e343bb&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201804%2F07%2F20180407100734_vdAQr.jpeg", cv: "梶 裕貴")
        self.feedModelList.append(nishikata)
        
        let rie = VoiceActor.init(id : 7, name: "高橋 李依", avator: "http://i0.hdslb.com/bfs/article/6d01ec26a667ec6dd59b58b3c7b817022b55be21.jpg")
        self.feedModelList.append(rie)
        
        let kaji = VoiceActor.init(id : 8, name: "梶裕贵", avator: "http://singerimg.kugou.com/uploadpic/softhead/400/20150716/20150716121533301476.jpg")
        self.feedModelList.append(kaji)
    }
}
