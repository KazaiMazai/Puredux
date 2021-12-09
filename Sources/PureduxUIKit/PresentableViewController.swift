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
                        removeStateDuplicates by: Equating<State> = .neverEqual) {

        let Presenter = Presenter(
            viewController: self,
            store: store,
            props: props,
            presentationQueue: presentationQueue,
            removeStateDuplicates: by.predicate)

        self.presenter = Presenter
    }
}

