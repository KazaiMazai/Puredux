//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18/04/2024.
//

import Foundation

final class Referenced<T> {
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}
