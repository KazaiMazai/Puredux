//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import SwiftUI
import PureduxCommon
 
struct PresentationSettings<AppState> {
    var removeDuplicates: (AppState, AppState) -> Bool
    var queue: PresentationQueue

    static var `default`: PresentationSettings {
        PresentationSettings(
            removeDuplicates: Equating.neverEqual.predicate,
            queue: .sharedPresentationQueue
        )
    }
}
