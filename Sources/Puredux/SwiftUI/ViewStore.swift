//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 28/08/2024.
//

import SwiftUI

@propertyWrapper
struct ViewStore<T> {
    private var cancellable = AnyCancellableEffect()
    private(set) var store: T
    
    var wrappedValue: T {
        get { store }
        set { store = newValue }
    }
}

extension ViewStore {
    init<S, A>(wrappedValue: @escaping (AnyCancellableEffect) -> T) where T == Store<S, A> {
        self.store = wrappedValue(cancellable)
    }
    
    init<S, A>(wrappedValue: @escaping (AnyCancellableEffect) -> T) where T == StateStore<S, A> {
        self.store = wrappedValue(cancellable)
    }
}

