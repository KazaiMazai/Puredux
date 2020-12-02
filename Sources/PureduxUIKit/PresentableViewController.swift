//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxStore

public protocol Presenter { }

public protocol PresentableViewController: class {
    associatedtype Props

    var presenter: Presenter { get set }
    func render(props: Props)
}

public extension PresentableViewController {
    func connect<VCPresenter: ViewControllerPresenter>(with presenter: VCPresenter,
                                                     to store: Store<VCPresenter.State, VCPresenter.Action>)
    where
        VCPresenter.ViewController.Props == Props {

        let presenter = Presenting(viewController: self, store: store, map: presenter.map)
        self.presenter = presenter
        store.subscribe(observer: presenter.asObserver)
    }
}
