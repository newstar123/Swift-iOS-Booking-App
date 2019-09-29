//
//  Drawing.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/5/18.
//  Copyright © 2018 Qorum. All rights reserved.
//

import CoreGraphics

/// Layer that needs implicit block with drawing implementation
class Drawing: CALayer {
    
    private var onDraw: ((CGContext) -> ())?
    
    required init(_ onDraw: @escaping (_ in: CGContext) -> ()) {
        self.onDraw = onDraw
        super.init()
        self.needsDisplayOnBoundsChange = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        onDraw?(ctx)
    }
    
    @discardableResult
    func with(frame rect: CGRect) -> Drawing {
        frame = rect
        
        return self
    }
}
