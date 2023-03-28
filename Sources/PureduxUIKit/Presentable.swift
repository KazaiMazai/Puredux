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

        let presenter = Presenter(
            viewController: self,
            store: store,
            props: props,
            presentationQueue: presentationQueue,
            removeStateDuplicates: equating.predicate)

        self.presenter = presenter
    }

    func with<State, Action>(store: StoreObject<State, Action>,
                             props: @escaping (State, Store<State, Action>) -> Self.Props,
                             presentationQueue: PresentationQueue = .sharedPresentationQueue,
                             removeStateDuplicates equating: Equating<State> = .neverEqual) {

        let presenter = StoreObjectPresenter(
            viewController: self,
            storeObject: store,
            props: props,
            presentationQueue: presentationQueue,
            removeStateDuplicates: equating.predicate)

        self.presenter = presenter
    }
}
