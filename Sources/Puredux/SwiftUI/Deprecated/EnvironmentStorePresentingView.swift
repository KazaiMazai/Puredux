//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine


struct EnvironmentStorePresentingView<AppState, Action, Props, Content>: View where Content: View {

    @EnvironmentObject private var store: RootEnvStore<AppState, Action>

    let content: ViewWithStore<AppState, Action, Props, Content>
    let presentationSettings: PresentationSettings<AppState>

    var body: some View {
        ViewWithPublishingStore(
            store: store.store(),
            content: content,
            presentationSettings: presentationSettings
        )
    }
}



