//
//  ServiceButton.swift
//  Qorum
//
//  Created by Yonat Sharon on 2016-05-30.
//  Copyright © 2016 Qorum. All rights reserved.
//


/// Button for showing and activating a service: Uber, Telephone.
class ServiceButton: DetailButton {

    var action: (() -> Void)? = nil

    init() {
        super.init(font: .boldFont(15), detailFont: .boldFont(15), style: .value1)
        //frame = CGRectMake(5, 0, .deviceWidth - 10, 50)
        let wd = (1250/1333) * .deviceWidth
        let ht = wd * (180/1250)
        frame = CGRect(x: (.deviceWidth - wd) / 2, y: 0, width: wd, height: ht)
        margin = 10
        layoutMargins = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        backgroundColor = .lightBlueColor
        tintColor = .white
        _ = constrain(self.icon, at: .width, to: self.icon, at: .height)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapped() {
        action?()
    }

    func adjustWithPhone(_ phoneNumber: String) {
        icon.image = UIImage(named: "phone_icon")
        title.text = NSLocalizedString("PHONE", comment: "")
        detail.text = phoneNumber
        action = { [weak self] in
            guard let phone_number = self?.detail.text else {return}
            guard let encoded_number = phone_number.addingPercentEncoding(withAllowedCharacters: CharacterSet.decimalDigits) else {return}
            guard let url = URL(string: "telprompt://" + encoded_number) else {return}
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }

    func adjustWithUber(fromVenue venue: Venue) {
        icon.image = UIImage(named: "uber-badge2")
        title.text = NSLocalizedString("UBER", comment: "")

        if venue.distance < 0.1 {
            detail.text = NSLocalizedString("GET A RIDE FROM HERE", comment: "")
        }
        else if let estimate = venue.uberEstimates.first {
            if let duration = estimate.duration, let priceRange = estimate.priceRange {
                let minutes = Int(round(Float(duration)/60.0))
                detail.text = String(format: NSLocalizedString("%d min,  %@", comment: ""), arguments: [minutes, priceRange])
            }
            else {
                let priceRange = estimate.priceRange ?? ""
                detail.text = String(format: NSLocalizedString("%@", comment: ""), arguments: [priceRange])
            }
        }
        else {
            detail.text = NSLocalizedString("TOO FAR", comment: "")
        }

        action = { [weak self] in
            UberController.sharedController.openUberApp()
            let sb = UIStoryboard(name: "UberDetailController", bundle: nil)
            let uberController = sb.instantiateViewController(withIdentifier: "UberDetailController") as! UberDetailController
            uberController.venue = venue
            if self?.detail.text == NSLocalizedString("GET A RIDE FROM HERE", comment: "") {
                uberController.rideFromVenue = true
            }
            //uberController.adjustWithVenue()
            (UIApplication.shared.delegate as? AppDelegate)?.mainController?.navigationController?.pushViewController(uberController, animated: true)
        }
    }
}
