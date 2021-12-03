//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

public enum StoreQueue {
    case main
    case backgroundQueue(label: String = "com.puredux.store", qos: DispatchQoS = .userInteractive)
}

public final class RootStore<State, Action> {
    public typealias Reducer = (inout State, Action) -> Void

    private let store: InternalStore<State, Action>

    public init(queue: StoreQueue = .backgroundQueue(label: "com.puredux.store", qos: .userInteractive),
                initial state: State,
                reducer: @escaping Reducer) {

        store = InternalStore(
            queue: queue,
            initial: state,
            reducer: reducer)
    }

    func getStore() -> Store<State, Action> {
        Store(dispatch: { [weak store] in store?.dispatch($0) },
              subscribe: { [weak store] in store?.subscribe(observer: $0) })
    }
}
