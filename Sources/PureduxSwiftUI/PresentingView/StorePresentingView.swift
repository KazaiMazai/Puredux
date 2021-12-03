//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import SwiftUI
import Combine


fileprivate extension DispatchQueue {
    static let sharedPresentationQueue = DispatchQueue(label: "com.puredux.swiftui.presentation",
                                                       qos: .userInteractive)
}

struct StorePresentingView<AppState, Action, Props, Content: View>: View {

    let store: PublishingStore<AppState, Action>

    @State private var currentProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let props: (_ state: AppState, _ store: PublishingStore<AppState, Action>) -> Props
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
        case .main:
            return makePropsPublisherReceiveOn(.main)
        case .serialQueue(let queue):
            return makePropsPublisherReceiveOn(queue)
        case .sharedPresentationQueue:
            return makePropsPublisherReceiveOn(.sharedPresentationQueue)
        }
    }

    func makePropsPublisherReceiveOn(_ queue: DispatchQueue) -> AnyPublisher<Props, Never> {
        store.statePublisher
            .receive(on: queue)
            .removeDuplicates(by: removeDuplicates)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
