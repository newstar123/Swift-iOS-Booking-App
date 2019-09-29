//
//  FriendsSectionController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/1/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import IGListKit

class FriendsSectionController: ListSectionController {

    var friends: GridAvatars?
    
    deinit { }
    
    override init() {
        super.init()
    }
    
    override func numberOfItems() -> Int {
        return friends?.avatars.count ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: .deviceWidth/2, height: .deviceWidth/2)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: FriendViewCell
        cell = collectionContext!.dequeueReusableCell(withNibName: "FriendViewCell", bundle: nil, for: self, at: index) as! FriendViewCell
        if let friend = friends?.avatars[index] {
            cell.setup(with: friend)
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        friends = object as? GridAvatars
    }
    
}
