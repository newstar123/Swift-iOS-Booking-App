//
//  ProfilePresenter.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/3/17.
//  Copyright (c) 2017 Bizico. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ProfilePresentationLogic: class {
    
    /// Presents current state
    ///
    /// - Parameter response: state model to present
    func present(response: Profile.Response)
}

class ProfilePresenter {
    weak var viewController: ProfileDisplayLogic?
}

// MARK: - ProfilePresentationLogic
extension ProfilePresenter: ProfilePresentationLogic {
    
    func present(response: Profile.Response) {
        switch response {
        case .user:
            let user = User.stored
            let name = "\(user.firstName ?? "") \(user.lastName ?? "")"
            let saved = "$\(user.totalSaved.monetaryValue)"
            let verificationState: Profile.VerificationState
            switch true {
            case user.isPhoneVerified && user.isEmailVerified:
                verificationState = .verified
            case user.isPhoneVerified:
                verificationState = .needsVerifyEmail
            case user.isEmailVerified:
                verificationState = .needsVerifyPhone
            default:
                verificationState = .needsVerifyPhoneAndEmail
            }
            let userData = Profile.UserData(imageURL: user.avatarURL,
                                            name: name,
                                            saved: saved,
                                            verificationState: verificationState)
            viewController?.display(viewModel: .user(userData))
        case let .loading(uploadState):
            viewController?.display(viewModel: .loading(uploadState))
        case let .mail(recipient, subject, body):
            viewController?.display(viewModel: .mail(recipients: [NSLocalizedString(recipient, comment: "")],
                                                     subject: NSLocalizedString(subject, comment: ""),
                                                     body: NSLocalizedString(body, comment: "")))
        case .userLoggedOut:
            viewController?.display(viewModel: .userLoggedOut)
        }
    }
    
}