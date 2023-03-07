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

    private(set) var storeType: StoreType<AppState, LocalState, ChildState, Action>
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
    func useStore(_ store: ChildStore<AppState, LocalState, ChildState, Action>) -> Self {
        var view = self
        view.storeType = .childStore(store)
        return view
    }

    func useStore(_ store: ScopeStore<AppState, ChildState>) -> Self {
        var view = self
        view.storeType = .scopeStore(store)
        return view
    }
}

public extension ViewWithStore {
    init(props: @escaping (ChildState, PublishingStore<ChildState, Action>) -> Props,
         content: @escaping (Props) -> Content,
         removeStateDuplicates equating: Equating<ChildState> = .neverEqual,
         queue: PresentationQueue = .sharedPresentationQueue) {

        storeType = .rootStore
        presenter = Presenter(
            props: props,
            content: content,
            removeDuplicates: equating.predicate,
            queue: queue
        )
    }
}

public extension ViewWithStore where Props == (ChildState, PublishingStore<ChildState, Action>) {
    init(content: @escaping (Props) -> Content,
         removeStateDuplicates equating: Equating<ChildState> = .neverEqual,
         queue: PresentationQueue = .sharedPresentationQueue) {

        storeType = .rootStore
        presenter = Presenter(
            props: { state, store in (state, store) },
            content: content,
            removeDuplicates: equating.predicate,
            queue: queue
        )
    }
}


//
//public extension ViewWithStore {
//    init(store: ScopeStore<AppState, ChildState>,
//         props: @escaping (ChildState, PublishingStore<ChildState, Action>) -> Props,
//         content: @escaping (Props) -> Content,
//         removeStateDuplicates equating: Equating<ChildState> = .neverEqual,
//         queue: PresentationQueue = .sharedPresentationQueue) {
//
//        storeType = .scopeStore(store)
//        presenter = Presenter(
//            props: props,
//            content: content,
//            removeDuplicates: equating.predicate,
//            queue: queue
//        )
//    }
//}

//
//
//public extension ViewWithStore {
//    init(store: ChildStore<AppState, LocalState, ChildState, Action>,
//         props: @escaping (ChildState, PublishingStore<ChildState, Action>) -> Props,
//         content: @escaping (Props) -> Content,
//         removeStateDuplicates equating: Equating<ChildState> = .neverEqual,
//         queue: PresentationQueue = .sharedPresentationQueue) {
//
//        storeType = .childStore(store)
//        presenter = Presenter(
//            props: props,
//            content: content,
//            removeDuplicates: equating.predicate,
//            queue: queue
//        )
//    }
//}
//
