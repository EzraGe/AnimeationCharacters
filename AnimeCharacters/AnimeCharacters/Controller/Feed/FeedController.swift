//
//  FeedController.swift
//  AnimeCharacters
//
//  Created by 戈宇泽 on 2019/8/5.
//  Copyright © 2019 戈宇泽. All rights reserved.
//

import UIKit

class FeedController : BaseController, UITableViewDataSource, UITableViewDelegate {
    
    var viewModel : FeedViewModel = FeedViewModel()
    
    var feedList : UITableView = UITableView()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController!.setNavigationBarHidden(true, animated: false)

        self.viewModel.mockData()
        self.viewModel.controller = self
        
        self.view.addSubview(self.feedList)
        self.feedList.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight  - bottomSafeAreaHeight - 49)
        self.feedList.register(AnimeStoryListCell.self, forCellReuseIdentifier: AnimeStoryListCell.cellReuseIdentifier)
        self.feedList.register(CharacterListCell.self, forCellReuseIdentifier: CharacterListCell.cellReuseIdentifier)
        self.feedList.register(VoiceActorListCell.self, forCellReuseIdentifier: VoiceActorListCell.cellReuseIdentifier)
        self.feedList.register(ADCell.self, forCellReuseIdentifier: ADCell.cellReuseIdentifier)
        self.feedList.dataSource = self
        self.feedList.delegate = self
        self.feedList.showsVerticalScrollIndicator = false
        self.feedList.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.feedList.contentInset = .init(top: hasSafeArea ? 24 : 8, left: 0, bottom: 0, right: 0)
        
        if #available(iOS 11.0, *) {
            self.feedList.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancelFavouriteNoficationRecieved(_:)), name: NSNotification.Name(rawValue: CancelFavouriteNotification), object: nil)
    }
    
    @objc func cancelFavouriteNoficationRecieved(_ notification : Notification) {
        let data : CollectionModel = notification.userInfo!["data"] as! CollectionModel
        self.viewModel.cancelFavourite(for: data)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows();
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.viewModel.cellForRow(at: indexPath) ?? UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.viewModel.select(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.heightForCell(at: indexPath)
    }
}

