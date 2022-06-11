//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

struct EnvironmentStorePresentingView<AppState, Action, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var store: RootEnvStore<AppState, Action>

    let props: (_ state: AppState, _ store: PublishingStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content
    let removeDuplicates: (AppState, AppState) -> Bool
    let queue: PresentationQueue

    var body: some View {
        StorePresentingView(
            store: store.store(),
            props: props,
            content: content,
            removeDuplicates: removeDuplicates,
            queue: queue)
    }
}



