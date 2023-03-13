//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import SwiftUI
import Combine
import PureduxStore
import PureduxCommon

struct ViewWithRootStore<AppState, Action, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var storeFactory: EnvStoreFactory<AppState, Action>

    let content: ViewWithStore<AppState, Action, Props, Content>
    private(set) var presentationSettings: PresentationSettings<AppState>

    var body: some View {
        ViewWithPublishingStore(
            store: storeFactory.rootStore(),
            content: content,
            presentationSettings: presentationSettings
        )
    }
}
