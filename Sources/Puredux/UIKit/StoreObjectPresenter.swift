//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//



struct StoreObjectPresenter<State, Action, ViewController> where ViewController: Presentable {

    let storeObject: StoreObject<State, Action>
    let presenter: Presenter<State, Action, ViewController>

    init(viewController: ViewController,
         storeObject: StoreObject<State, Action>,
         props: @escaping (State, Store<State, Action>) -> ViewController.Props,
         presentationQueue: PresentationQueue,
         removeStateDuplicates isEqual: @escaping (State, State) -> Bool) {

        self.storeObject = storeObject
        self.presenter = Presenter(
            viewController: viewController,
            store: storeObject.store(),
            props: props,
            presentationQueue: presentationQueue,
            removeStateDuplicates: isEqual
        )
    }
}

extension StoreObjectPresenter: PresenterProtocol {
    func subscribeToStore() {
        presenter.subscribeToStore()
    }
}
