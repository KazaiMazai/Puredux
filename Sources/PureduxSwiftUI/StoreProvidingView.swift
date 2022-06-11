//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import SwiftUI

public struct StoreProvidingView<AppState, Aciton, Content: View>: View {
    private let rootStore: RootEnvStore<AppState, Aciton>
    private let content: () -> Content

    public var body: some View {
        content().environmentObject(rootStore)
    }

    public init(rootStore: RootEnvStore<AppState, Aciton>,
                content: @escaping () -> Content) {
        self.rootStore = rootStore
        self.content = content
    }
}

