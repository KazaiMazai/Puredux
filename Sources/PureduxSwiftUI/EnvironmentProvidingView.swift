//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import SwiftUI

public struct EnvironmentProvidingView<State, Action, Content: View, SomeView: View>: View {
    let environment: Environment<State, Action, Content, SomeView>

    let content: () -> Content

    
    public var body: some View {
        environment
            .injection(content())
            .environmentObject(environment.store)
    }
    
    public init(environment: Environment<State, Action, Content, SomeView>,
                content: @escaping () -> Content) {
        self.environment = environment
        self.content = content
    }
}
