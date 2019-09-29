//
//  TipFeaturesHoursController.swift
//  Qorum
//
//  Created by Michael Wilson on 9/21/15.
//  Copyright © 2015 Qorum. All rights reserved.
//

import UIKit
import SDWebImage

protocol TipFeaturesHoursDelegate: NSObjectProtocol {
    var featuresHeight: NSLayoutConstraint! { get set }
    func showMenuPressed()
}

class TipFeaturesHoursController: UIPageViewController {
    
    let menuButton = DetailButton(font: UIFont.montserrat.medium(14), detailFont: UIFont.montserrat.regular(12), title: NSLocalizedString("VIEW MENU", comment: ""))
    weak var featuresDelegate: TipFeaturesHoursDelegate?
    let tipsController = UIViewController()
    let featuresController = UIViewController()
    let hoursController = UIViewController()
    let swipeBetweenViews = SwipeBetweenViews(frame: CGRect(x: 0, y: 0, width: .deviceWidth, height: 32))
    var venue: Venue?
    
    var tipsMaxY:CGFloat = 0
    var featuresMaxY:CGFloat = 0
    var hoursMaxY:CGFloat = 0
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(transitionStyle:.scroll, navigationOrientation:.horizontal, options:nil)
        setup()
    }
    
    convenience init () {
        self.init(transitionStyle:.scroll, navigationOrientation:.horizontal, options:nil)
        setup()
    }
    
    private func setup() {
        swipeBetweenViews.pageViewController = self
        swipeBetweenViews.viewControllerArray = [tipsController, featuresController, hoursController]
        swipeBetweenViews.buttonTextArray = [NSLocalizedString("INSIDE  TIPS", comment:""), NSLocalizedString("FEATURES", comment:""), NSLocalizedString("HOURS", comment:"")]
        swipeBetweenViews.isAsset = true
        swipeBetweenViews.adjustWithPageViewController()
        
        self.view.addSubview(swipeBetweenViews)
        
        self.view.clipsToBounds = false
        self.view.subviews.first?.clipsToBounds = false
        
        menuButton.tintColor = .white
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = menuButton.tintColor.cgColor
        menuButton.layer.cornerRadius = 5
        menuButton.frame = CGRect(x: 15, y: 0, width: .deviceWidth - 30, height: 50)
        menuButton.backgroundColor = #colorLiteral(red: 0.01960784314, green: 0.05098039216, blue: 0.1450980392, alpha: 1)
        view.addSubview(menuButton)
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
    }
    
    func adjustWithVenue() {
        adjustWithFeatures()
        adjustWithTips()
        adjustWithHours()
        adjustWithMenu()
    }
    
    private func adjustWithFeatures() {
        let _ = featuresController.view.subviews.map { $0.removeFromSuperview() }
        guard let venue = venue, let metadata = Metadata.stored else { return }
        
        var YOffset: CGFloat = 48
        for feature in venue.features {
            if let featureTemplate = metadata.features.first(where: { $0.identifier == feature.name }) {
                let featuresLabel = UILabel(frame: CGRect(x: 46, y: YOffset, width: .deviceWidth - 85, height: 18))
                featuresLabel.textColor = UIColor.detailsFeaturesGrey
                featuresLabel.font = UIFont.montserrat.regular(14)
                let featuresIcon = UIImageView(frame: CGRect(x: 16, y: YOffset - 1, width: 18, height: 20))
                featuresIcon.image = nil
                featuresIcon.contentMode = .scaleAspectFit
                if let data = feature.data, let label = featureTemplate.label, featureTemplate.requiresData {
                    if let url = featureTemplate.icon_url {
                        featuresIcon.sd_setImage(with: URL(string: url), completed: {(image, error, cacheType, imageURL) -> Void in
                        })
                    }
                    var text = ""
                    var range = (label as NSString).range(of: "%@")
                    if range.length > 0 {
                        if let priceAvg = venue.priceAvg, feature.name == "avgDrinkPrice" {
                            let priceAvgString = "$\(priceAvg.monetaryValue)"
                            text = String(format:label, arguments:[priceAvgString])
                            range.length = (priceAvgString as NSString).length
                        } else if let patronAgeAvg = venue.patronAgeAvg, feature.name == "avgGuestAge" {
                            let patronAgeAvgString = String(patronAgeAvg)
                            text = String(format:label, arguments:[patronAgeAvgString])
                            range.length = (patronAgeAvgString as NSString).length
                        } else {
                            text = String(format:label, arguments:[data])
                            range.length = (data as NSString).length
                        }
                        
                        let newText = NSMutableAttributedString(string: text)
                        if (feature.name == "avgDrinkPrice" || feature.name == "avgGuestAge" || feature.name == "avgWaitTime") && data != "0" {
                            newText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(hex: "00abdd")!, range: range)
                            newText.addAttribute(NSAttributedStringKey.font, value: UIFont.montserrat.medium(14), range: range)
                        } else {
                            newText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.detailsFeaturesGrey, range: range)
                        }
                        featuresLabel.attributedText = newText
                    } else {
                        featuresLabel.text = text
                    }
                    featuresController.view.addSubview(featuresLabel)
                    featuresController.view.addSubview(featuresIcon)
                } else if let text = featureTemplate.label, !featureTemplate.requiresData {
                    if let url = featureTemplate.icon_url {
                        featuresIcon.sd_setImage(with: URL(string: url), completed: {(image, error, cacheType, imageURL) -> Void in
                        })
                        featuresController.view.addSubview(featuresIcon)
                    }
                    featuresLabel.text = text
                    featuresController.view.addSubview(featuresLabel)
                }
                YOffset += 34
            }
        }
        featuresMaxY = YOffset
        featuresController.view.height = YOffset
    }
    
    private func adjustWithTips() {
        let _ = tipsController.view.subviews.map { $0.removeFromSuperview() }
        guard let venue = venue, let metadata = Metadata.stored else {return}
        
        var YOffset: CGFloat = 48
        
        //Add avgDrinkPrice and avgGuestAge to all tips
        if let priceAvg = venue.priceAvg {
            let avgPriceLabel = UILabel(font: UIFont.montserrat.regular(14), textColor: UIColor.detailsFeaturesGrey, text: "")
            avgPriceLabel.frame = CGRect(x: 46, y: YOffset, width: .deviceWidth - 85, height: 18)
            
            let priceAvgString = "$\(priceAvg.monetaryValue)"
            let text = "\(priceAvgString) Average Drink Price"
            let attrString = NSMutableAttributedString(string: text)
            var range = (text as NSString).range(of: priceAvgString)
            range.length = (priceAvgString as NSString).length
            
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(hex: "00abdd")!, range: range)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont.montserrat.medium(14), range: range)
            avgPriceLabel.attributedText = attrString
            let tipsIcon = UIImageView(frame: CGRect(x: 16, y: YOffset - 1, width: 18, height: 20))
            tipsIcon.image = nil
            tipsIcon.contentMode = .scaleAspectFit
            let featureTemplate = metadata.insiderTips.first(where: { $0.identifier ==  "avgDrinkPrice" })
            if let url = featureTemplate?.icon_url {
                tipsIcon.sd_setImage(with: URL(string: url), completed: {(image, error, cacheType, imageURL) -> Void in
                })
            }
            
            tipsController.view.addSubview(tipsIcon)
            tipsController.view.addSubview(avgPriceLabel)
            YOffset += 34
        }
        if let avgAge = venue.patronAgeAvg {
            let avgAgeLabel = UILabel(font: UIFont.montserrat.regular(14), textColor: UIColor.detailsFeaturesGrey, text: "")
            avgAgeLabel.frame = CGRect(x: 46, y: YOffset, width: .deviceWidth - 85, height: 18)
            
            let avgAgeString = String(avgAge)
            let text = "\(avgAgeString) Average Guest Age"
            let attrString = NSMutableAttributedString(string: text)
            var range = (text as NSString).range(of: avgAgeString)
            range.length = (avgAgeString as NSString).length
            
            attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(hex: "00abdd")!, range: range)
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont.montserrat.medium(14), range: range)
            avgAgeLabel.attributedText = attrString
            
            let tipsIcon = UIImageView(frame: CGRect(x: 16, y: YOffset - 1, width: 18, height: 20))
            tipsIcon.image = nil
            tipsIcon.contentMode = .scaleAspectFit
            let featureTemplate = metadata.insiderTips.first(where: { $0.identifier ==  "avgGuestAge" })
            if let url = featureTemplate?.icon_url {
                tipsIcon.sd_setImage(with: URL(string: url), completed: {(image, error, cacheType, imageURL) -> Void in
                })
            }
            
            tipsController.view.addSubview(tipsIcon)
            tipsController.view.addSubview(avgAgeLabel)
            YOffset += 34
        }
        
        var whatToDrink = ""
        var howsTheCrowd = ""
        for insider_tip in venue.insider_tips {
            
            if let featureTemplate = metadata.insiderTips.first(where: { $0.identifier ==  insider_tip.name }) {
                let tipsLabel = UILabel(frame: CGRect(x: 46, y: YOffset, width: .deviceWidth - 85, height: 18))
                tipsLabel.textColor = UIColor.detailsFeaturesGrey
                tipsLabel.font = UIFont.montserrat.regular(14)
                tipsLabel.numberOfLines = 0
                let tipsIcon = UIImageView(frame: CGRect(x: 16, y: YOffset - 1, width: 18, height: 20))
                tipsIcon.image = nil
                tipsIcon.contentMode = .scaleAspectFit
                if let data = insider_tip.data, let label = featureTemplate.label, featureTemplate.requiresData {
                    
                    if insider_tip.name != "whatToDrink" && insider_tip.name != "crowd" {
                        if let url = featureTemplate.icon_url {
                            tipsIcon.sd_setImage(with: URL(string: url), completed: {(image, error, cacheType, imageURL) -> Void in
                            })
                        }
                    }
                    var range = (label as NSString).range(of: "%@")
                    if range.length > 0 {
                        let text = String(format:label, arguments:[data])
                        range.length = (data as NSString).length
                        
                        let newText = NSMutableAttributedString(string: text)
                        if insider_tip.name == "avgDrinkPrice" || insider_tip.name == "avgGuestAge" {
                            continue
                        } else if insider_tip.name == "avgWaitTime" && data != "0" {
                            newText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(hex: "00abdd")!, range: range)
                            newText.addAttribute(NSAttributedStringKey.font, value: UIFont.montserrat.medium(14), range: range)
                        } else {
                            newText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.detailsFeaturesGrey, range: range)
                        }
                        tipsLabel.attributedText = newText
                        
                        if insider_tip.name == "whatToDrink" {
                            whatToDrink = text
                        }
                        if insider_tip.name == "crowd" {
                            howsTheCrowd = text
                        }
                    } else {
                        tipsLabel.text = ""
                    }
                    if insider_tip.name != "whatToDrink" && insider_tip.name != "crowd" {
                        tipsController.view.addSubview(tipsLabel)
                        tipsController.view.addSubview(tipsIcon)
                        tipsLabel.sizeToFit()
                        YOffset += tipsLabel.height + 16
                    }
                } else if let text = featureTemplate.label, !featureTemplate.requiresData {
                    if let url = featureTemplate.icon_url {
                        tipsIcon.sd_setImage(with: URL(string: url), completed: {(image, error, cacheType, imageURL) -> Void in
                        })
                        tipsController.view.addSubview(tipsIcon)
                    }
                    tipsLabel.text = text
                    tipsController.view.addSubview(tipsLabel)
                    tipsLabel.sizeToFit()
                    YOffset += tipsLabel.height + 16
                }
            }
        }
//        if (whatToDrink as NSString).length > 0 || (howsTheCrowd as NSString).length > 0 {
//            YOffset += 20
//        }
        
        if (whatToDrink as NSString).length > 0 {
            let arr = whatToDrink.components(separatedBy: "What to Drink: ")
            if arr.count > 1 {
                let whatToDrinkLabel = UILabel()
                whatToDrinkLabel.width = self.view.width - 34
                whatToDrinkLabel.height = 22
                whatToDrinkLabel.text = "What to drink".uppercased()
                whatToDrinkLabel.textColor = .white
                whatToDrinkLabel.font = UIFont.montserrat.medium(16)
                
                let drinkSize = whatToDrinkLabel.sizeThatFits(CGSize(width: .deviceWidth - 85, height: 10000))
                whatToDrinkLabel.frame = CGRect(x: 17, y: YOffset, width: drinkSize.width, height: drinkSize.height)
                let descriptionLabel1 = UILabel()
                descriptionLabel1.font = UIFont.montserrat.regular(14)
                descriptionLabel1.numberOfLines = 0
                descriptionLabel1.width = self.tipsController.view.width - 34
                descriptionLabel1.textColor = UIColor.detailsFeaturesGrey
                descriptionLabel1.text = arr[1]
                // descriptionLabel1.sizeToFit()
                let descriptionSize = descriptionLabel1.sizeThatFits(CGSize(width: .deviceWidth - 19, height: 10000))
                descriptionLabel1.frame = CGRect(x: 17, y: whatToDrinkLabel.y + whatToDrinkLabel.height + 6, width: descriptionSize.width, height: descriptionSize.height)
                
                tipsController.view.addSubview(whatToDrinkLabel)
                tipsController.view.addSubview(descriptionLabel1)
                
                YOffset += whatToDrinkLabel.height + descriptionLabel1.height + 22
            }
        }
        if (howsTheCrowd as NSString).length > 0 {
            let arr = howsTheCrowd.components(separatedBy: "Crowd: ")
            if arr.count > 1 {
                let whatToDrinkLabel = UILabel()
                whatToDrinkLabel.font = UIFont.montserrat.medium(16)
                whatToDrinkLabel.width = self.view.width - 34
                whatToDrinkLabel.height = 22
                whatToDrinkLabel.textColor = .white
                whatToDrinkLabel.text = "How's the crowd".uppercased()
                let drinkSize = whatToDrinkLabel.sizeThatFits(CGSize(width: .deviceWidth - 85, height: 10000))
                // whatToDrinkLabel.sizeToFit()
                whatToDrinkLabel.frame = CGRect(x: 17, y: YOffset, width: drinkSize.width, height: drinkSize.height)
                let descriptionLabel1 = UILabel()
                descriptionLabel1.font = UIFont.montserrat.regular(14)
                descriptionLabel1.numberOfLines = 0
                descriptionLabel1.width = self.tipsController.view.width - 34
                var crowd = arr[1]
                if crowd.contains("other:") {
                    crowd = crowd.replacingOccurrences(of: "other:", with: "")
                }
                descriptionLabel1.text = crowd
                // descriptionLabel1.sizeToFit()
                let descriptionSize = descriptionLabel1.sizeThatFits(CGSize(width: .deviceWidth - 19, height: 10000))
                descriptionLabel1.frame = CGRect(x: 17, y: whatToDrinkLabel.y + whatToDrinkLabel.height + 6, width: descriptionSize.width, height: descriptionSize.height)
                descriptionLabel1.textColor = UIColor.detailsFeaturesGrey
                tipsController.view.addSubview(whatToDrinkLabel)
                tipsController.view.addSubview(descriptionLabel1)
                
                // whatToDrinkLabel.sizeToFit()
                // descriptionLabel1.sizeToFit()
                YOffset += whatToDrinkLabel.height + descriptionLabel1.height + 16
            }
        }
        
        tipsMaxY = YOffset
        tipsController.view.height = YOffset
    }
    
    private func adjustWithHours() {
        hoursController.view.subviews.forEach { $0.removeFromSuperview() }
        var YOffset: CGFloat = 48
        guard let venue = venue else { return }
        let now = Date()
        let currentWeekday: Int
        switch venue.status() {
        case .open(let openedDay, _), .closesSoon(_, let openedDay):
            currentWeekday = openedDay.component
        case .opensLater, .closed:
            currentWeekday = now.weekday.component
        }
        let schedules = venue.timeSlots.schedules()
        for weekday in Weekday.allCases {
            let daysLabel = UILabel(frame: CGRect(x: 17, y: YOffset, width: .deviceWidth, height: 18))
            daysLabel.textColor = UIColor.detailsFeaturesGrey
            daysLabel.font = UIFont.montserrat.regular(14)
            if weekday.component == currentWeekday {
                daysLabel.textColor = .white
            }
            daysLabel.text = weekday.localizedName.capitalized
            daysLabel.sizeToFit()
            hoursController.view.addSubview(daysLabel)
            let scheduleLookup = schedules
                .filter { $0.opening.weekday == weekday }
                .sorted { $0.duration > $1.duration }
                .first
            if let schedule = scheduleLookup {
                let hoursLabel = UILabel(frame: CGRect(x: 0, y: YOffset, width: .deviceWidth, height: 18))
                hoursLabel.textColor = UIColor.detailsFeaturesGrey
                hoursLabel.font = UIFont.montserrat.regular(14)
                hoursLabel.numberOfLines = 0
                hoursLabel.textAlignment = .right
                var aboutToClose = false
                if weekday.component == currentWeekday {
                    hoursLabel.textColor = .white
                    if case .closesSoon = venue.status() {
                        aboutToClose = true
                    }
                }
                hoursLabel.text = schedule.displayString
                hoursLabel.sizeToFit()
                hoursLabel.x = .deviceWidth - hoursLabel.width - 17
                hoursController.view.addSubview(hoursLabel)
                daysLabel.width = .deviceWidth - hoursLabel.width - 27
                daysLabel.sizeToFit()
                YOffset += (max(hoursLabel.height, daysLabel.height) + 6)
                if aboutToClose {
                    let closingLabel = UILabel(font: UIFont.opensans.semibold_italic(13), text: NSLocalizedString("Closing Soon!", comment: ""))
                    closingLabel.sizeToFit()
                    let closingY = YOffset - 6 //+ (max(hoursLabel.height, daysLabel.height) + 5)
                    closingLabel.origin = CGPoint(x: hoursLabel.frame.maxX - closingLabel.width, y: closingY)
                    hoursController.view.addSubview(closingLabel)
                    YOffset = closingLabel.frame.maxY + 6
                }
            } else {
                YOffset += 24
            }
        }
        hoursMaxY = YOffset
        hoursController.view.height = YOffset
    }
    
    private func adjustWithMenu() {
        self.menuButton.icon.image = UIImage(named: "menu_icon")
        
        let now = Date()
        if let currentKitchenSchedule = venue?.kitchenTimeSlots.schedule(onDayOf: now, calendar: .current) {
            let servedStr = currentKitchenSchedule.displayString
            let text = NSLocalizedString("SERVED FROM:\n", comment: "") + currentKitchenSchedule.displayString
            let attrString = NSMutableAttributedString(string: text)
            var range = (text as NSString).range(of: servedStr)
            range.length = (servedStr as NSString).length
            
            attrString.addAttribute(NSAttributedStringKey.font, value: UIFont.montserrat.medium(14), range: range)
            
            menuButton.detail.attributedText = attrString
        } else {
            menuButton.detail.text = nil
        }
        
        adjustOffsets(swipeBetweenViews.currentPage, animated: false)
    }
    
    func adjustOffsets(_ currentPage: Int, animated: Bool) {
        var offset: CGFloat = 0.0
        switch currentPage {
        case 0: offset = tipsMaxY + 6
        case 1: offset = featuresMaxY + 4
        case 2: offset = hoursMaxY + 14
        default: offset = max(tipsMaxY, featuresMaxY, hoursMaxY) + 4
        }
        
        featuresDelegate?.featuresHeight.constant = offset + self.menuButton.height
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.parent?.view.layoutIfNeeded()
                self.menuButton.y = offset
            }
        } else {
            self.parent?.view.layoutIfNeeded()
            self.menuButton.y = offset
        }
        
    }
    
    @objc func showMenu() {
        self.featuresDelegate?.showMenuPressed()
    }
}
