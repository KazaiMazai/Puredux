//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxStore

public protocol PresenterProtocol {
    func subscribeToStore()
}

public protocol PresentableViewController: AnyObject {
    associatedtype Props

    var presenter: PresenterProtocol? { get set }

    func setProps(_ props: Props)
}

public extension PresentableViewController {
    func connect<Presenter>(to store: Presenter.Store,
                            using viewControllerPresenter: Presenter)
        where
        Presenter: ViewControllerPresenter,
        Presenter.ViewController.Props == Props {

        let presenting = Presenting(
            viewController: self,
            store: store,
            props: viewControllerPresenter.props,
            workerQueue: viewControllerPresenter.makePresenterWorkerQueue(),
            distinctStateChangesBy: viewControllerPresenter.distinctStateChangesBy.predicate)

        self.presenter = presenting
    }
}
