//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import Foundation

@available(iOS 13.0, *)
public extension Equating where T: Identifiable {
    static var asIdentifiable: Equating {
        Equating {
            $0.id == $1.id
        }
    }
}
