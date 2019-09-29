//
//  FriendsContainerController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/1/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import IGListKit

/// The screen to display users checked in at the moment.
class FriendsContainerController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 4)
    }()
    
    var friends: [Avatar] = [] {
        didSet {
            adapter.performUpdates(animated: true, completion: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    // MARK: - Internal
    
    private func configureCollectionView() {
        self.automaticallyAdjustsScrollViewInsets = false
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
}

// MARK: - ListAdapterDataSource

extension FriendsContainerController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [GridAvatars(avatars: friends)]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return FriendsSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }
    
}

class GridAvatars: NSObject {
    
    let avatars: [Avatar]!
    
    init(avatars: [Avatar]) {
        self.avatars = avatars
        super.init()
    }

}
