//
//  SafeMailSender.swift
//  Qorum
//
//  Created by Stanislav on 29.11.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

////
////  SafeMailSender.swift
////  Workaround for MFMailComposeViewController crashes a la http://stackoverflow.com/a/25864182/1176162
////
////  Created by Yonat Sharon on 2016-05-15.
////

import MessageUI

protocol SafeMailSenderDelegate {
    func safeMailSenderDidFinish(with result: SafeMailSender.Result)
}

class SafeMailSender: NSObject {
    
    enum Result {
        case sent
        case saved
        case cancelled
        case failed(Error)
    }
    
    enum Presentation {
        case presented
        case wentToExternalMailApp
        case error(Error)
    }
    
    struct Attachment {
        let title: String
        let image: UIImage
    }
    
    static let shared = SafeMailSender()
    
    var delegate: SafeMailSenderDelegate?
    
    private var mailController: MFMailComposeViewController? // created way in advance to avoid crash
    
    private override init() {
        super.init()
        createMailController()
    }
    
    fileprivate func createMailController() {
        guard MFMailComposeViewController.canSendMail() else { return }
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        self.mailController = mailController
    }
    
    func send(to recipients: [String] = [],
              subject: String = "",
              body: String = "",
              attachment: Attachment? = nil,
              from viewController: UIViewController,
              completion: ((Presentation)->())? = nil)
    {
        guard let mailController = mailController else {
            guard let firstRecipient = recipients.first else {
                let message = "No mail account has been set up on your phone"
                UIAlertController.presentAsAlert(title: "Email Error",
                                                 message: message)
                completion?(.error(message))
                return
            }
            let coded = "mailto:\(firstRecipient)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? " "
            guard let emailURL: URL = URL(string: coded), UIApplication.shared.canOpenURL(emailURL) else {
                let message = "No mail account has been set up on your phone"
                UIAlertController.presentAsAlert(title: "Email Error",
                                                 message: message)
                completion?(.error(message))
                return
            }
            UIApplication.shared.open(emailURL, options: [:]) { _ in
                completion?(.wentToExternalMailApp)
            }
            return
        }
        mailController.setSubject(subject)
        mailController.setMessageBody("<html><body><p>\(body)</p></body></html>", isHTML: true)
        if  let attachment = attachment,
            let imageData = UIImageJPEGRepresentation(attachment.image, 1)
        {
            mailController.addAttachmentData(imageData,
                                             mimeType: "image/jpeg",
                                             fileName: "\(attachment.title).jpeg")
        }
        mailController.setToRecipients(recipients)
        DispatchQueue.main.async {
            viewController.present(mailController, animated: true) {
                completion?(.presented)
            }
        }
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate
extension SafeMailSender: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            self?.createMailController()
        }
        let safeMailSenderResult: Result
        switch result {
        case .sent:
            safeMailSenderResult = .sent
        case .saved:
            safeMailSenderResult = .saved
        case .cancelled:
            safeMailSenderResult = .cancelled
        case .failed:
            safeMailSenderResult = .failed(error ?? "Unexpected error")
        }
        delegate?.safeMailSenderDidFinish(with: safeMailSenderResult)
        delegate = .none
    }
    
}

