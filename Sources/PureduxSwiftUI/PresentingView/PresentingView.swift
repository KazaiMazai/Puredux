//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import SwiftUI
import Combine

fileprivate extension DispatchQueue {
    static let sharedPresentationQueue = DispatchQueue(
        label: "com.puredux.swiftui.presentation",
        qos: .userInteractive
    )
}

struct PresentingView<AppState, Action, Props, Content: View>: View {
    @State private var currentProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let store: PublishingStore<AppState, Action>
    let presenter: Presenter<AppState, Action, Props, Content>

    var body: some View {
        makeContent()
            .onReceive(propsPublisher) { self.currentProps = $0 }
            .onAppear { propsPublisher = makePropsPublisher() }
    }
}

private extension View {
    @ViewBuilder
    func onReceive<P>(_ publisher: P?, perform action: @escaping (P.Output) -> Void) -> some View where P: Publisher, P.Failure == Never {
        if let publisher = publisher {
            onReceive(publisher, perform: action)
        } else {
            self
        }
    }
}

private extension PresentingView {
    @ViewBuilder
    func makeContent() -> some View {
        if let props = currentProps {
            presenter.content(props)
        } else {
            Color.clear
        }
    }

    func makePropsPublisher() -> AnyPublisher<Props, Never> {
        switch presenter.queue {
        case .main:
            return makePropsPublisherWith(queue: .main)
        case .serialQueue(let queue):
            return makePropsPublisherWith(queue: queue)
        case .sharedPresentationQueue:
            return makePropsPublisherWith(queue: .sharedPresentationQueue)
        }
    }

    func makePropsPublisherWith(queue: DispatchQueue) -> AnyPublisher<Props, Never> {
        store.statePublisher
            .receive(on: queue)
            .removeDuplicates(by: presenter.removeDuplicates)
            .map { presenter.props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
