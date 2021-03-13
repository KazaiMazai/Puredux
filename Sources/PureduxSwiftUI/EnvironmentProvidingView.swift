//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import SwiftUI

public struct EnvironmentStoreProvidingView<AppState, Action, Content: View>: View {
    let store: EnvironmentStore<AppState, Action>
    let content: () -> Content

    public var body: some View {
        content().environmentObject(store)
    }

    public init(store: EnvironmentStore<AppState, Action>,
                content: @escaping () -> Content) {
        self.store = store
        self.content = content
    }
}

