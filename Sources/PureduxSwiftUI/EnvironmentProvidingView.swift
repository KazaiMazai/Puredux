//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import SwiftUI

public struct EnvironmentStoreProvidingView<State, Action, Content: View>: View {
    let store: EnvironmentStore<State, Action>
    let content: () -> Content

    public var body: some View {
        content()
            .environmentObject(store)
    }
    
    public init(store: EnvironmentStore<State, Action>,
                content: @escaping () -> Content) {
        self.store = store
        self.content = content
    }
}
