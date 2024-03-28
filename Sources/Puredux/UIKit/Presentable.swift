//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import Dispatch

public protocol PresenterProtocol {
    func subscribeToStore()
}

public protocol Presentable: AnyObject {
    associatedtype Props
    
    var presenter: PresenterProtocol? { get set }
    
    func setProps(_ props: Props)
}

public extension Presentable {
    func with<State, Action>(store: Store<State, Action>,
                             props: @escaping (State, Store<State, Action>) -> Self.Props,
                             presentationQueue: PresentationQueue = .sharedPresentationQueue,
                             removeStateDuplicates equating: Equating<State> = .neverEqual) {
 
        let weakStore = store.store()
        presenter = Presenter(
            store: store,
            observer: Observer(
                self,
                removeStateDuplicates: equating, 
                observe: { state, complete in
                    presentationQueue.dispatchQueue.async {
                        let props = props(state, weakStore)
                        
                        PresentationQueue.main.dispatchQueue.async { [weak self] in
                            self?.setProps(props)
                            complete(.active)
                        }
                    }
                }
            )
        )
    }
}
