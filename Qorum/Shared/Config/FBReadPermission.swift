//
//  FBReadPermission.swift
//  Qorum
//
//  Created by Stanislav on 1/25/19.
//  Copyright © 2019 Bizico. All rights reserved.
//

import UIKit

/// See https://developers.facebook.com/docs/facebook-login/permissions for full list of available permissions.
enum FBReadPermission: String, CaseIterable {
    case publicProfile
    case userFriends
    case email
    case userAboutMe
    case userActionsBooks
    case userActionsFitness
    case userActionsMusic
    case userActionsNews
    case userActionsVideo
    case userBirthday
    case userEducationHistory
    case userEvents
    case userGamesActivity
    case userGender
    case userHometown
    case userLikes
    case userLocation
    case userManagedGroups
    case userPhotos
    case userPosts
    case userRelationships
    case userRelationshipDetails
    case userReligionPolitics
    case userTaggedPlaces
    case userVideos
    case userWebsite
    case userWorkHistory
    case readCustomFriendlists
    case readInsights
    case readAudienceNetworkInsights
    case readPageMailboxes
    case pagesShowList
    case pagesManageCta
    case pagesManageInstantArticles
    case adsRead
}

// MARK: - Codable
extension FBReadPermission: Codable {
    
}
