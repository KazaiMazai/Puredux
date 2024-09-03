//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import SwiftUI
import Combine
/*
@available(*, deprecated, message: "Will be removed in 2.0")
struct ViewWithRootStore<AppState, Action, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var storeFactory: StateStore<AppState, Action>

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
*/
