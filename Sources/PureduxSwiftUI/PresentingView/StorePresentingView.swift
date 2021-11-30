//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import SwiftUI
import Combine

struct StorePresentingView<Store, AppState, Action, Props, Content>: View
    where
    Content: View,
    Store: ObservableStoreProtocol,
    Store.AppState == AppState,
    Store.Action == Action {

    let store: Store


    @State private var currentProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let props: (_ state: AppState, _ store: Store) -> Props
    let content: (_ props: Props) -> Content

    let removeDuplicates: (AppState, AppState) -> Bool
    let queue: PresentationQueue

    var body: some View {
        makeContent()
            .onReceive(propsPublisher) { self.currentProps = $0 }
            .onAppear { propsPublisher = makePropsPublisher() }
    }
}

private extension View {
    @ViewBuilder
    func onReceive<P>(_ publisher: P?, perform action: @escaping (P.Output) -> Void) -> some View where P : Publisher, P.Failure == Never {
        if let publisher = publisher {
            onReceive(publisher, perform: action)
        } else {
            self
        }
    }
}

private extension StorePresentingView {
    @ViewBuilder
    func makeContent() -> some View {
        if let props = currentProps {
            content(props)
        } else {
            Color.clear
        }
    }

    func makePropsPublisher() -> AnyPublisher<Props, Never> {
        switch queue {
        case .storeQueue:
            return makeStoreQueuePropsPublisher()
        case .main:
            return makeCustomQueuePropsPublisher(.main)
        case .queue(let queue):
            return makeCustomQueuePropsPublisher(queue)
        }
    }

    func makeStoreQueuePropsPublisher() -> AnyPublisher<Props, Never> {
        store.statePublisher
            .removeDuplicates(by: removeDuplicates)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func makeCustomQueuePropsPublisher(_ queue: DispatchQueue) -> AnyPublisher<Props, Never> {
        store.statePublisher
            .removeDuplicates(by: removeDuplicates)
            .receive(on: queue)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
