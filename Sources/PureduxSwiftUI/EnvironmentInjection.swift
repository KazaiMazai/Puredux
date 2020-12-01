//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import SwiftUI

public typealias EnvironmentInjection<C: View, V: View> = (C) -> V

public struct Environment<State, Action, C: View, V: View> {
    let store: EnvironmentStore<State, Action>

    var injection: EnvironmentInjection<C, V>

    public init(store: EnvironmentStore<State, Action>,
                injection: @escaping EnvironmentInjection<C, V>) {
        self.store = store
        self.injection = injection
    }
}

public struct EnvironmentProvidingView<State, Action, C: View, V: View>: View {
    let environment: Environment<State, Action, C, V>

    let content: () -> C
    public var body: some View {
        environment
            .injection(content())
            .environmentObject(environment.store)
    }
}
