//
//  NSObject+IGListDiffable.swift
//  Botl
//
//  Created by Dima Tsurkan on 3/20/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import Foundation
import IGListKit

// MARK: - IGListDiffable
extension NSObject: ListDiffable {
    
    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
    
}
