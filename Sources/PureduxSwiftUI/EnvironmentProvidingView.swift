//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import SwiftUI

public struct EnvironmentStoreProvidingView<Store: StoreProtocol, Content: View>: View {
    private let store: ObservableStore<Store>
    private let content: () -> Content

    public var body: some View {
        content().environmentObject(store)
    }

    public init(store: ObservableStore<Store>,
                content: @escaping () -> Content) {
        self.store = store
        self.content = content
    }
}

