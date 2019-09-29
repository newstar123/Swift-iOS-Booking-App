//
//  TriangleDownView.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/10/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

class TriangleDownView: UIView {
    let colorLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        colorLayer.fillColor = UIColor.lightBlueColor.cgColor
        self.layer.addSublayer(colorLayer)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path.close()
        colorLayer.path = path.cgPath
    }
}
