//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import SwiftUI

public struct StoreProvidingView<AppState, Aciton, Content: View>: View {
    private let store: ObservableStore<AppState, Aciton>
    private let content: () -> Content

    public var body: some View {
        content().environmentObject(store)
    }

    public init(store: ObservableStore<AppState, Aciton>,
                content: @escaping () -> Content) {
        self.store = store
        self.content = content
    }
}

