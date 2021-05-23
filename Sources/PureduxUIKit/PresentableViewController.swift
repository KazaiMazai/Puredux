//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxStore

public protocol PresentableViewController: class {
    associatedtype Props

    var presenter: PresenterProtocol? { get set }

    func setProps(_ props: Props)
}

public extension PresentableViewController {
    func use<Presenter: ViewControllerPresenter>(
        _ viewControllerPresenter: Presenter,
        connectingTo store: Store<Presenter.State, Presenter.Action>)

        where
        Presenter.ViewController.Props == Props {

        let presenting = Presenting(
            viewController: self,
            store: store,
            props: viewControllerPresenter.props)

        self.presenter = presenting
    }
}
