//
//  QorumProgressHUD.swift
//  QorumProgressHUD
//
//  All rights reserved.
//

import UIKit

/**
 Type of QorumProgressHUD's background view.
 
 - **clear:** `UIColor.clear`.
 - **white:** `UIColor(white: 1, alpho: 0.2)`.
 - **black:** `UIColor(white: 0, alpho: 0.2)`. Default type.
 - **custom:** You can set custom mask color.
 */
public enum QorumProgressHUDMaskType {
    case clear, white, black, custom(color: UIColor)

    var maskColor: UIColor {
        switch self {
        case .clear: return .clear
        case .white: return UIColor(white: 1, alpha: 0.2)
        case .black: return UIColor(white: 0, alpha: 0.2)
        case .custom(let color): return color
        }
    }
}

/**
 Style of QorumProgressHUD.
 
 - **white:**          HUD's backgroundColor is `.white`. HUD's text color is `.black`. Default style.
 - **black:**           HUD's backgroundColor is `.black`. HUD's text color is `.white`.
 - **custom(background, text, icon):**  You can set custom color of HUD's background, text and glyph icon.
 If you set nil to `icon`, it's shown in original color.
 */
public enum QorumProgressHUDStyle {
    case white
    case black
    case custom(background: UIColor, text: UIColor, icon: UIColor?)

    var backgroundColor: UIColor {
        switch self {
        case .white: return .white
        case .black: return .black
        case .custom(let style): return style.background
        }
    }

    var textColor: UIColor {
        switch self {
        case .white: return .black
        case .black: return .white
        case .custom(let style): return style.text
        }
    }

    var iconColor: UIColor? {
        switch self {
        case .custom(let style): return style.icon
        default: return nil
        }
    }
}

/**
 *  QorumProgressHUD is a beautiful and easy-to-use progress HUD.
 */
public final class QorumProgressHUD {
    public typealias CompletionHandler = () -> Void

    public class QorumProgressHUDAppearance {
        /// Default style.
        public var style = QorumProgressHUDStyle.white
        /// Default mask type.
        public var maskType = QorumProgressHUDMaskType.black
        /// Default message label font.
        public var font = UIFont.systemFont(ofSize: 13)
        /// Default HUD center offset of y axis.
        public var viewOffset = CGFloat(0.0)
        /// Default time to show HUD.
        public var deadlineTime = Double(1.0)

        fileprivate init() {}
    }

    static let shared = QorumProgressHUD()

    let viewAppearance = QorumProgressHUDAppearance()

    let window = UIWindow(frame: UIScreen.main.bounds)
    let hudViewController = QorumProgressHUDViewController()

    let hudView = UIView()
    let iconView = UIView()
    let activityIndicatorView = QorumLoadingView(frame: .zero)
    let iconDrawingView = UIView()
    let iconDrawingLayer = CAShapeLayer()
    let imageView = UIImageView()
    let messageLabel = UILabel()

    var style: QorumProgressHUDStyle?
    var maskType: QorumProgressHUDMaskType?
    var font: UIFont?
    var viewOffset: CGFloat?
    var deadlineTime: Double?

    var hudViewCenterYConstraint: NSLayoutConstraint!
    var hudViewSideMarginConstraints = [NSLayoutConstraint]()
    var iconViewConstraints = [NSLayoutConstraint]()
    var messageLabelConstraints = [NSLayoutConstraint]()
    var messageLabelMinWidthConstraint: NSLayoutConstraint!

    var dismissHandler: DispatchWorkItem?
    weak var appWindow: UIWindow?
    weak var presentingViewController: UIViewController?

    /// This have whether HUD is indicated.
    public internal(set) static var isVisible = false

    private init() {
        configureProgressHUDView()
    }
}

// MARK: - Set styles --------------------------

extension QorumProgressHUD {
    /**
     Returns the appearance proxy for the receiver.
     
     - returns: The appearance proxy for the receiver.
     */
    public static func appearance() -> QorumProgressHUDAppearance {
        return shared.viewAppearance
    }

    /**
     Sets the HUD style.
     This value is cleared by `resetStyles()`.
     
     - parameter style: QorumProgressHUDStyle
     
     - returns: QorumProgressHUD.Type (discardable)
     */
    @discardableResult public static func set(style: QorumProgressHUDStyle) -> QorumProgressHUD.Type {
        shared.style = style
        return QorumProgressHUD.self
    }

    /**
     Sets the HUD mask type.
     This value is cleared by `resetStyles()`.
     
     - parameter maskType: QorumProgressHUDMaskType
     
     - returns: QorumProgressHUD.Type (discardable)
     */
    @discardableResult public static func set(maskType: QorumProgressHUDMaskType) -> QorumProgressHUD.Type {
        shared.maskType = maskType
        return QorumProgressHUD.self
    }

    /**
     Sets the HUD message label font.
     This value is cleared by `resetStyles()`.
     
     - parameter font: the message label font.
     
     - returns: QorumProgressHUD.Type (discardable)
     */
    @discardableResult public static func set(font: UIFont) -> QorumProgressHUD.Type {
        shared.font = font
        return QorumProgressHUD.self
    }

    /**
     Sets the HUD center offset of y axis.
     This value is cleared by `resetStyles()`.

     - parameter viewOffset: the HUD center offset of y axis.

     - returns: QorumProgressHUD.Type (discardable)
     */
    @discardableResult public static func set(viewOffset offset: CGFloat) -> QorumProgressHUD.Type {
        shared.viewOffset = offset
        return QorumProgressHUD.self
    }

    /**
     Sets deadline time to show HUD.

     This is used:
     - `showSuccess()`
     - `showInfo()`
     - `showWarning()`
     - `showError()`
     - `showImage()`
     - `showMessage()`

     This value is cleared by `resetStyles()`.

     - parameter time: deadline time.

     - returns: QorumProgressHUD.Type (discardable)
     */
    @discardableResult public static func set(deadlineTime time: Double) -> QorumProgressHUD.Type {
        shared.deadlineTime = time
        return QorumProgressHUD.self
    }

    /**
     Resets the HUD styles.
     
     - returns: QorumProgressHUD.Type (discardable)
     */
    @discardableResult public static func resetStyles() -> QorumProgressHUD.Type {
        shared.style = nil
        shared.maskType = nil
        shared.font = nil
        shared.viewOffset = nil
        shared.deadlineTime = nil
        return QorumProgressHUD.self
    }

    /**
     Sets the view controller which presents HUD.
     This is applied only once.
     
     - parameter viewController: Presenting view controller.
     
     - returns: QorumProgressHUD.Type
     */
    public static func showOn(_ viewController: UIViewController) -> QorumProgressHUD.Type {
        shared.presentingViewController = viewController
        return QorumProgressHUD.self
    }
}

// MARK: - Show, Update & Dismiss --------------------------

extension QorumProgressHUD {
    /**
     Shows the HUD.
     You can appoint only the args which You want to appoint.
     
     - parameter message:    HUD's message (option).
     - parameter completion: Show completion handler (option).
     */
    public static func show(withMessage message: String? = nil, completion: CompletionHandler? = nil) {
        shared.show(withMessage: message, isLoading: true, completion: completion)
    }

    /**
     Shows the HUD with success glyph.
     The HUD dismiss after 1 secound (Default).
     
     - parameter message: HUD's message (option).
     */
    public static func showSuccess(withMessage message: String? = nil) {
        shared.show(withMessage: message, iconType: .success)
    }

    /**
     Shows the HUD with information glyph.
     The HUD dismiss after 1 secound (Default).
     
     - parameter message: HUD's message (option).
     */
    public static func showInfo(withMessage message: String? = nil) {
        shared.show(withMessage: message, iconType: .info)
    }

    /**
     Shows the HUD with warning glyph.
     The HUD dismiss after 1 secound (Default).
     
     - parameter message: HUD's message (option).
     */
    public static func showWarning(withMessage message: String? = nil) {
        shared.show(withMessage: message, iconType: .warning)
    }

    /**
     Shows the HUD with error glyph.
     The HUD dismiss after 1 secound (Default).
     
     - parameter message: HUD's message (option).
     */
    public static func showError(withMessage message: String? = nil) {
        shared.show(withMessage: message, iconType: .error)
    }

    /**
     Shows the HUD with image.
     The HUD dismiss after 1 secound (Default).
     
     - parameter image:   Image that display instead of activity indicator.
     - parameter message: HUD's message (option).
     */
    public static func showImage(_ image: UIImage, size: CGSize? = nil, message: String? = nil) {
        shared.show(withMessage: message, image: image, imageSize: size)
    }

    /**
     Shows the message only HUD.
     The HUD dismiss after 1 secound (Default).
     
     - parameter message: HUD's message.
     */
    public static func showMessage(_ message: String) {
        shared.show(withMessage: message, isOnlyText: true)
    }

    /**
     Updates the HUD message.
     
     - parameter message: String
     */
    public static func update(message: String) {
        shared.messageLabel.text = message
    }

    /**
     Hides the HUD.
     
     - parameter completion: Hide completion handler (option).
     */
    public static func dismiss(_ completion: CompletionHandler? = nil) {
        shared.dismiss(completion: completion)
    }
}
