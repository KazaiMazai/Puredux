//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.06.2021.
//

import Foundation
import PureduxStore

public protocol StoreProtocol {
    associatedtype AppState
    associatedtype Action

    func dispatch(_ action: Action)

    func subscribe(observer: Observer<AppState>) 
}

extension PureduxStore.Store: StoreProtocol {
    
}
