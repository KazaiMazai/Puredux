//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.03.2023.
//

import SwiftUI
import Combine
import PureduxStore
import PureduxCommon

public struct ViewWithStore<AppState, LocalState, ChildState, Action, Props, Content>: View
    where
    Content: View {

    let storeType: StoreType<AppState, LocalState, ChildState, Action>
    let presenter: Presenter<ChildState, Action, Props, Content>

    public var body: some View {
        switch storeType {
        case .rootStore:
            ViewWithRootStore(presenter: presenter)
        case .childStore(let childStore):
            ViewWithChildStore(childStore: childStore, presenter: presenter)
        case .scopeStore(let scopeStore):
            ViewWithScopeStore(scopeStore: scopeStore, presenter: presenter)
        }
    }
}

public extension ViewWithStore {
    init(store: ChildStore<AppState, LocalState, ChildState, Action>,
         props: @escaping (ChildState, PublishingStore<ChildState, Action>) -> Props,
         content: @escaping (Props) -> Content,
         removeStateDuplicates equating: Equating<ChildState> = .neverEqual,
         queue: PresentationQueue) {

        storeType = .childStore(store)
        presenter = Presenter(
            props: props,
            content: content,
            removeDuplicates: equating.predicate,
            queue: queue
        )
    }
}

public extension ViewWithStore {
    init(store: ScopeStore<AppState, ChildState>,
         props: @escaping (ChildState, PublishingStore<ChildState, Action>) -> Props,
         content: @escaping (Props) -> Content,
         removeStateDuplicates equating: Equating<ChildState> = .neverEqual,
         queue: PresentationQueue) {

        storeType = .scopeStore(store)
        presenter = Presenter(
            props: props,
            content: content,
            removeDuplicates: equating.predicate,
            queue: queue
        )
    }
}

public extension ViewWithStore where AppState == ChildState {
    init(props: @escaping (AppState, PublishingStore<AppState, Action>) -> Props,
         content: @escaping (Props) -> Content,
         removeStateDuplicates equating: Equating<AppState> = .neverEqual,
         queue: PresentationQueue) {

        storeType = .rootStore
        presenter = Presenter(
            props: props,
            content: content,
            removeDuplicates: equating.predicate,
            queue: queue
        )
    }
}
