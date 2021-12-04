//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

public enum StoreQueue {
    case main
    case global(qos: DispatchQoS = .userInteractive)
}

public typealias Interceptor<Action> = (Action) -> Void
public typealias Reducer<State, Action> = (inout State, Action) -> Void

public final class RootStore<State, Action> {
    private let store: InternalStore<State, Action>

    public init(queue: StoreQueue = .global(qos: .userInteractive),
                initial state: State,
                reducer: @escaping Reducer<State, Action>) {

        store = InternalStore(
            queue: queue,
            initial: state,
            reducer: reducer)
    }
}

public extension RootStore {

    func getStore() -> Store<State, Action> {
        Store(dispatch: { [weak store] in store?.dispatch($0) },
              subscribe: { [weak store] in store?.subscribe(observer: $0) })
    }

    func interceptActions(with interceptor: @escaping Interceptor<Action>) {
        store.interceptActions(with: interceptor)
    }
}
