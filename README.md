<p align="center">
  <img src="Logo.svg?raw=true" alt="Sublime's custom image"/>
 </p>
 

UIKit bindings to connect UI to PureduxSrore
<p align="left">
    <a href="https://github.com/KazaiMazai/PureduxUIKit/actions">
        <img src="https://github.com/KazaiMazai/PureduxUIKit/workflows/Tests/badge.svg" alt="Continuous Integration">
    </a>
</p>

## Features

- Clear path to data-driven UIViewControllers
- Presentation data model aka. 'Props' can be prepared on Main or Background queue
- State updates deduplication to avoid unnecessary UI refresh

____________


## Installation
 

### Swift Package Manager.

PureduxStore is available through Swift Package Manager. 
To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/PureduxUIKit
```
____________

## Quick Start Guide

1. Import:
```swift
import PureduxUIKit

```

2. Implement view controller and conform it to `Presentable`

```swift

final class FancyViewController: UIViewController, Presentable {
    var presenter: PresenterProtocol? { get set }

    //update views here
    func setProps(_ props: Props) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.subscribeToStore()
    }
}

extension FancyViewController {
    struct Props {
        let title: String
        let onTap: () -> Void
    }
}

```


3.  Prepare `Props` with current state and store. For e.g. as a part of some fancy presenter:

```swift

struct FancyVCPresenter {
    //prepare props for your fancy view controller
    func makeProps(state: FancyFeatureState, 
                   store: Store<FancyFeatureState, Action>) -> FancyViewController.Props {
        
        Props(title: "Hello"
              onTap: {
                  store.dispatch(
                      FancyTapAction()
                  )
              }
        )
    }
}

```

4.  Connect your fancy view controller to store, providing **how** it should be connected:

```swift
let appState = AppState()
let factory = StoreFactory<AppState, Action>(initialState: appState, reducer: reducer)

let fancyFeatureStore = rootStore.scopeStore { $0.yourFancyFeatureSubstate }
 
let presenter = FancyVCPresenter()
let viewController = FancyViewController()

viewController.with(store: fancyFeatureStore,
                    props: presenter.makeProps)
 
```


5. Present it immediately!


## Q&A

<details><summary>Click for details</summary>
<p>


### What is PureduxStore?

- It's minilistic UDF architecture store implementation. More details can be found [here](https://github.com/KazaiMazai/PureduxStore)

### Which DispatchQueue is used to prepare props?

- By default, it works on a shared PresentationQueue. It is a global serial queue with user interactive quality of service. The purpose is to do as little as possible on the main thread queue.
  
  
### Is it safe at all?
  
- PureduxUIKit hops to the main dispatch queue to update UIViewController. So yes, it's safe. Unless you try to do UIKit related things (you should not) during your `Props` preparation.  

### How to change  presentation queue that is used to prepare props?


- PureduxUIKit allows to use main queue or user-provided custom queue. The only requirement for the custom queue is to be **serial** one.

```swift 
viewController.with(store: fancyFeatureStore,
                    props: presenter.makeProps,
                    presentationQueue: .main)
                    
```

or standalone queue:
              
```swift       

let queue = DispatchQueue(label: "some.queue", qos: .userInteractive)

viewController.with(store: fancyFeatureStore,
                    props: presenter.makeProps,
                    presentationQueue: .serialQueue(queue))
        
```

### How to deduplicate state changes?

- State deduplication is done by providing a way to compare two states on equality.
- It's done with the help of `Equating<State>` guy:

```swift 

viewController.with(store: fancyFeatureStore,
                    props: presenter.makeProps,
                    removeStateDuplicates: .equal {
                        $0.title
                    })
                    
```

### Why we need `Equating<State>` guy?

- Depending on context (or particular screen), we might be interested in different part of the state. Different properties of the same type.
- And would like to deduplicate updates depending on it.
- That's why single `Equatable` implementation won't work here.

```swift 

firstViewController.with(store: fancyFeatureStore,
                        props: firstVCpresenter.makeProps,
                        removeStateDuplicates: .equal {
                            $0.title
                        })
                    
secondViewController.with(store: fancyFeatureStore,
                    props: secondVCpresenter.makeProps,
                    removeStateDuplicates: .equal {
                        $0.subtitle
                    })
                    
```

### Any other `Equating<State>`  details ?

- Equating is a protocol witness for Equtable. It answers the question: "Are these states equal?" 
- With the help of it, deduplication happens.

Here is the definition:

```swift
  
    Equating<T> { (lhs: T, rhs: T) -> Bool
        //compare here
    }

```

It has handy extensions, like  `Equating.alwaysEqual` or `Equating.neverEqual` as well as `&&` operator:

```swift 

viewController.with(store: fancyFeatureStore,
                    props: vcPresenter.makeProps,
                    removeStateDuplicates: 
                        .equal { $0.title } &&
                        .equal { $0.subtitle }
                    )
            
```


</p>
</details>


## Licensing

PureduxUIKit is licensed under MIT license.
