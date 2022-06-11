//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import Foundation
import PureduxCommon

public extension Equating where T: Identifiable {
    static var asIdentifiable: Equating {
        Equating {
            $0.id == $1.id
        }
    }
}

