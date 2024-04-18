//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18/04/2024.
//

import Foundation

final class Weak<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}
