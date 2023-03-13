//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09.03.2023.
//

import SwiftUI
import PureduxStore
import PureduxCommon

public struct ViewWithStore<ViewState, Action, Props, Content: View>: View {
    private let props: (_ state: ViewState, _ store: PublishingStore<ViewState, Action>) -> Props
    private let content: (_ props: Props) -> Content
    private var presentationSettings: PresentationSettings<ViewState> = .default

    public var body: some View {
        ViewWithRootStore(
            content: self,
            presentationSettings: presentationSettings
        )
    }
}

public extension ViewWithStore {
    func removeStateDuplicates(_ equating: Equating<ViewState>) -> Self {
        var selfCopy = self
        selfCopy.presentationSettings.removeDuplicates = equating.predicate
        return selfCopy
    }

    func usePresentationQueue(_ queue: PresentationQueue) -> Self {
        var selfCopy = self
        selfCopy.presentationSettings.queue = queue
        return selfCopy
    }
}

public extension ViewWithStore {
    init(props: @escaping (ViewState, PublishingStore<ViewState, Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.props = props
        self.content = content
    }

    init(props: @escaping (ViewState, Dispatch<Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.props = { state, store in props(state, store.dispatch) }
        self.content = content
    }
}

public extension ViewWithStore where Props == (ViewState, PublishingStore<ViewState, Action>) {
    init(_ content: @escaping (Props) -> Content) {
        self.props = { state, store in (state, store) }
        self.content = content
    }
}

public extension ViewWithStore where Props == (ViewState, Dispatch<Action>) {
    init(_ content: @escaping (Props) -> Content) {
        self.props = { state, store in (state, store.dispatch) }
        self.content = content
    }
}

public extension ViewWithStore {
    func store(_ store: PublishingStore<ViewState, Action>) -> some View {
        ViewWithPublishingStore(
            store: store,
            content: self,
            presentationSettings: presentationSettings
        )
    }

    func scopeStore<AppState>(to localState: @escaping (AppState) -> ViewState) -> some View {
        ViewWithScopeStore(
            localState: localState,
            content: self,
            presentationSettings: presentationSettings
        )
    }

    func childStore<AppState, ChildState>(initialState: ChildState,
                                          stateMapping: @escaping (AppState, ChildState) -> ViewState,
                                          qos: DispatchQoS = .userInteractive,
                                          reducer: @escaping Reducer<ChildState, Action>) -> some View {

        ViewWithChildStore(
            initialState:initialState,
            stateMapping: stateMapping,
            qos: qos,
            reducer: reducer,
            content: self,
            presentationSettings: presentationSettings
        )
    }

    func childStore<AppState, ChildState>(initialState: ChildState,
                                          qos: DispatchQoS = .userInteractive,
                                          reducer: @escaping Reducer<ChildState, Action>) -> some View

    where ViewState == (AppState, ChildState) {

        ViewWithChildStore(
            initialState:initialState,
            stateMapping: { ($0, $1) },
            qos: qos,
            reducer: reducer,
            content: self,
            presentationSettings: presentationSettings
        )
    }
}
