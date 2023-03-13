//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import SwiftUI
import Combine
import PureduxCommon

fileprivate extension DispatchQueue {
    static let sharedPresentationQueue = DispatchQueue(
        label: "com.puredux.swiftui.presentation",
        qos: .userInteractive
    )
}

struct ViewWithPublishingStore<AppState, Action, Props, Content: View>: View {
    @State private var currentProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let store: PublishingStore<AppState, Action>
    let content: ViewWithStore<AppState, Action, Props, Content>
    var presentationSettings: PresentationSettings<AppState> 

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

private extension ViewWithPublishingStore {
    @ViewBuilder
    func makeContent() -> some View {
        if let props = currentProps {
            content.content(props)
        } else {
            Color.clear
        }
    }

    func makePropsPublisher() -> AnyPublisher<Props, Never> {
        switch presentationSettings.queue {
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
            .removeDuplicates(by: presentationSettings.removeDuplicates)
            .map { content.props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

