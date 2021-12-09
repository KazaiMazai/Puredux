//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxStore
import PureduxCommon

public protocol PresenterProtocol {
    func subscribeToStore()
}

public protocol PresentableViewController: AnyObject {
    associatedtype Props

    var presenter: PresenterProtocol? { get set }

    func setProps(_ props: Props)
}

public extension PresentableViewController {

    func with<State, Action>(store: Store<State, Action>,
                        props: @escaping (State, Store<State, Action>) -> Self.Props,
                        presentationQueue: PresentationQueue = .sharedPresentationQueue,
                        distinctStateChangesBy: Equating<State> = .neverEqual) {

        let presenting = Presenting(
            viewController: self,
            store: store,
            props: props,
            presentationQueue: presentationQueue,
            distinctStateChangesBy: distinctStateChangesBy.predicate)

        self.presenter = presenting
    }
}

