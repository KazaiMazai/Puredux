//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import SwiftUI

public typealias EnvironmentInjection<Content: View, SomeView: View> = (Content) -> SomeView

public struct Environment<State, Action, Content: View, SomeView: View> {
    let store: EnvironmentStore<State, Action>

    var injection: EnvironmentInjection<Content, SomeView>

    public init(store: EnvironmentStore<State, Action>,
                injection: @escaping EnvironmentInjection<Content, SomeView>) {
        self.store = store
        self.injection = injection
    }
}
