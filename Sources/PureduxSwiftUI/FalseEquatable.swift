//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import Foundation

public protocol FalseEquatable: Equatable {

}

extension FalseEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        false
    }
}
