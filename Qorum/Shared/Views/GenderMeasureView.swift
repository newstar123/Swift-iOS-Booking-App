//
//  GenderMeasureView.swift
//  Qorum
//
//  Created by Dmitry Tsurkan on 11/19/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

protocol GenderMeasureViewDataSource: class {
    func values(forView genderView: GenderMeasureView) -> (male: Int, female: Int)
}

class GenderMeasureView: UIView {

    weak var dataSource: GenderMeasureViewDataSource? {
        didSet { reloadData() }
    }
    
    private lazy var leftLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.backgroundColor = User.Gender.male.color
        l.textAlignment = .center
        l.font = UIFont.montserrat.medium(14)
        return l
    }()
    
    private lazy var rightLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.backgroundColor = User.Gender.female.color
        l.textAlignment = .center
        l.font = UIFont.montserrat.medium(14)
        return l
    }()
    
    private var leftWidthConstraint: NSLayoutConstraint?
    private var rightWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// Configures UI
    private func setupView() {
        addSubview(leftLabel)
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        leftLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        leftLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        
        addSubview(rightLabel)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        rightLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        rightLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
    }
    
    /// Updates UI
    ///
    /// - Parameters:
    ///   - male: male value
    ///   - female: female value
    private func setValues(male: Int, female: Int) {
        /// Negative check
        guard male >= 0, female >= 0 else {
            let message = """
            GenderMeasureView issue:
            setValues(male: Int, female: Int) was called with a negative parameter:
            male: \(male), female: \(female)
            """
            debugPrint(message)
            return
        }
        
        var maleValue = CGFloat(male) / CGFloat(male + female)
        var femaleValue = 1 - maleValue
        if male == 0, female == 0 {
            maleValue = 0
            femaleValue = 0
        }
        let leftPercentage = Int((maleValue * 100).rounded(.toNearestOrAwayFromZero))
        let rightPercentage = femaleValue == 0 ? 0 : 100-leftPercentage
        
        /// Prevent label squashing
        var leftMultiplier = maleValue
        var rightMultiplier = femaleValue
        let minimumMultiplier: CGFloat = 0.15
        
        if leftMultiplier < minimumMultiplier, leftMultiplier != 0 {
            leftMultiplier = minimumMultiplier
            rightMultiplier = 1 - leftMultiplier
        } else if rightMultiplier < minimumMultiplier, rightMultiplier != 0 {
            rightMultiplier = minimumMultiplier
            leftMultiplier = 1 - rightMultiplier
        }
        
        if let leftWidthConstraint = leftWidthConstraint {
            leftLabel.removeConstraint(leftWidthConstraint)
        }
        if let rightWidthConstraint = rightWidthConstraint {
            rightLabel.removeConstraint(rightWidthConstraint)
        }
        leftWidthConstraint = leftLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: leftMultiplier)
        leftWidthConstraint?.isActive = true
        rightWidthConstraint = rightLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: rightMultiplier)
        rightWidthConstraint?.isActive = true
        layoutIfNeeded()
        
        leftLabel.text = "\(leftPercentage)%"
        rightLabel.text = "\(rightPercentage)%"
    }
    
    /// Reloads data
    func reloadData() {
        if let values = dataSource?.values(forView: self) {
            setValues(male: values.male, female: values.female)
        }
    }
    
}
