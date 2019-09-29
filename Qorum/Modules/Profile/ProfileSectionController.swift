//
//  ProfileSectionController.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/3/17.
//  Copyright © 2017 Dima Tsurkan. All rights reserved.
//

import Foundation
import IGListKit

final class ProfileSectionController: ListSectionController, ListSupplementaryViewSource {
    
    private var displayedMenu: Profile.FetchProfile.ViewModel.DisplayedProfileMenu?
    private let cellsBeforeHeader = 6
      
    deinit {
       
    }
    
    override init() {
        super.init()
        supplementaryViewSource = self
    }
    
    // MARK: IGListSectionController Overrides
    
    override func numberOfItems() -> Int {
        return cellsBeforeHeader
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = self.collectionContext?.containerSize.width ?? 0
        let height: CGFloat = 47
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: ProfileMenuCell.self, for: self, at: index) as! ProfileMenuCell
        cell.menu = displayedMenu?.menuItems[index]
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        displayedMenu = object as? Profile.FetchProfile.ViewModel.DisplayedProfileMenu
    }
    
    override func didSelectItem(at index: Int) {
        if index == 0 {
            (viewController as! ProfileViewController).router?.routeToEditProfile()
        } else if index == 3 {
            (viewController as! ProfileViewController).router?.routeToPayments()
        } else if index == 4 {
            (viewController as! ProfileViewController).router?.routeToSettings()
        } else if index == 5 {
            (viewController as! ProfileViewController).logout()
        }
    }
    
    // MARK: ListSupplementaryViewSource
    
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        guard let view = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                             for: self,
                                                                             nibName: "UserHeaderView",
                                                                             bundle: nil,
                                                                             at: index) as? UserHeaderView else {
                                                                                fatalError()
        }
        view.delegate = self
        view.image = displayedMenu?.header
        view.saved = (displayedMenu?.userInfo.savedDescription)! + " " + (displayedMenu?.userInfo.savedAmount)!
        view.name = displayedMenu?.userInfo.userName
        return view
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 370)
    }
    
}


// MARK: - UserHeaderViewDelegate

extension ProfileSectionController: UserHeaderViewDelegate {
    
    func backButtonPressed() {
        (viewController as! ProfileViewController).router?.dissmissVC()
    }
    
    func photoButtonPressed() {
        (viewController as! ProfileViewController).showActionSheet()
    }
}

