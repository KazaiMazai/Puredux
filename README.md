<p align="center">
  <img src="Logo.svg?raw=true" alt="Sublime's custom image"/>
 </p>
 

SwiftUI bindings to connect UI to PureduxStore


## Features

- Сlean and reusable SwiftUI's Views without dependencies
- Presentation data model aka. 'Props' can be prepared on Main or Background queue
- State updates deduplication to avoid unnecessary UI refresh

____________


## Installation
 

### Swift Package Manager.

PureduxSwiftUI is available through Swift Package Manager. 
To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/PureduxSwiftUI
```
____________

## Quick Start Guide

1. Import:
```swift
import PureduxSwiftUI

```

2. Implement your `FancyView`, explicitly declaring it's `Props` as an input: 

```swift
struct FancyView: View {
    let props: Props
    
    var body: some View {
        Text(props.title)
            .onAppear { props.didAppear() }
    }
}

extension FancyView {
    struct Props {
        let title: String
        let didAppear: Command
    }
}

```

```swift
typealias Command = () -> Void

```

3.  Prepare `Props` with current state and store. For e.g. as a part of some fancy presenter:

```swift

struct FancyViewPresenter {
    func makeProps(
        state: FancyFeatureState, 
        store: PublishingStore<FancyFeatureState, Action>) -> FancyView.Props {
        
        //prepare props for your fancy view
    }
}

```

4. Connect your fancy view to the store, providing **how** it should be connected:

```swift
let appState = AppState()
let rootStore = RootStore<AppState, Action>(initialState: appState, reducer: reducer)
let rootEnvStore = RootEnvStore(rootStore: rootStore)
let fancyFeatureStore = rootEnvStore.store().proxy { $0.yourFancyFeatureSubstate }

let presenter = FancyViewPresenter() 
            
UIHostingController(
    rootView: FancyView.with(
        store: fancyFeatureStore,
        props: presenter.makeProps,
        content: { FancyView(props: $0) }
    )
)
 
```

## Q&A

<details><summary>Click for details</summary>
<p>


### What is PureduxStore?

- It's minilistic UDF architecture store implementation. More details can be found [here](https://github.com/KazaiMazai/PureduxStore)

### Which DispatchQueue is used to prepare props?

- By default, it works on a shared PresentationQueue. It is a global serial queue with user interactive quality of service. The purpose is to do as little as possible on the main thread queue.
  
  
### Is it safe at all?
  
- PureduxSwiftUI hops to the main dispatch queue to update View. So yes, it's safe. Unless you try to do UI related things (you should not) during your `Props` preparation.  

### How to change  presentation queue that is used to prepare props?


- PureduxSwiftUI allows to use main queue or user-provided custom queue. The only requirement for the custom queue is to be **serial** one.

```swift 
FancyView.with(
    store: fancyFeatureStore,
    props: presenter.makeProps,
    queue: .main,
    content: { FancyView(props: $0) }
)
  
```

or standalone queue:
              
```swift       
let queue = DispatchQueue(label: "some.queue", qos: .userInteractive)
  
```
  
  
```swift
  
FancyView.with(
    store: fancyFeatureStore,
    props: presenter.makeProps,
    queue: .serialQueue(queue),
    content: { FancyView(props: $0) }
)
        
```
### Why we might need to prepare props on background queue?
  
- Props evaluation maybe heavier than we would love to. 
We may deal with a large array of items, AttributedStrings, and any other slow things.
Doing it on the main queue may eventually slow down our fancy app.

### How to deduplicate state changes?

- State deduplication is done by providing a way to compare two states on equality.
- It allows to avoid props evaluation on every state update
- It's done with the help of `Equating<State>` guy:

```swift 

 FancyView.with(
    store: fancyFeatureStore,
    removeStateDuplicates: .equal {
        $0.title
    },
    props: presenter.makeProps,
    content: { FancyView(props: $0) }
)
                    
```
### Why we might need to deduplicate state changes?
  
- Props evaluation maybe heavier than we would love to. 
The app state may be huuuuge and we might love to re-evaluate `Props` only when it's necessary.

### Why we need `Equating<State>` guy?

- Depending on context (or particular screen), we might be interested in different part of the state. Different properties of the same type.
- And would like to deduplicate updates depending on it.
- That's why single `Equatable` implementation won't work here.

```swift 
VStack {  
    FancyView.with(
        store: fancyFeatureStore,
        removeStateDuplicates: .equal {
            $0.title
        },
        props: presenter.makeProps,
        content: { FancyView(props: $0) }
    )

    FancyView.with(
        store: fancyFeatureStore,
        removeStateDuplicates: .equal {
            $0.subtitle
        },
        props: presenter.makeProps,
        content: { FancyView(props: $0) }
    )
}               
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
  
FancyView.with(
    store: fancyFeatureStore,
    removeStateDuplicates: 
        .equal { $0.title } &&
        .equal { $0.subtitle },
    props: presenter.makeProps,
    content: { FancyView(props: $0) }
)
            
```

### How to connect View to Store ?
  
- There are two ways of doing it: with explicit in implicit store.
  
Explicit store:

```swift
  
UIHostingController(
    rootView: FancyView.with(
        store: fancyFeatureStore,
        props: presenter.makeProps,
        content: { FancyView(props: $0) }
    )
)
  
```
Implicit env store:
  
```swift
  
UIHostingController(
    rootView: StoreProvidingView(rootStore: rootStore) {
  
        FancyView.withEnvStore(
            props: presenter.makeProps,
            content: { FancyView(props: $0) }  
        )
    }
)

```
  
### How implicit store is passed?
- It's injected via `environmentObject(...)` and then resolved as `@EnvironmentObject`
  
  
### When explicit/implicit store should be used?
Explicit:
- Explicit store should be used when we want to pass the store explicitly as a parameter
- Explicit store is preferable when aiming to isolate features from the entire AppState
  
Implicit:  
- Implicit store should be used when we are ok with `EnvironmentObject` injections
- Implicit store should be used when we are ok with exposing the entire AppState to features
  
  
### Any other advices?
  
- I would recommend to separate plain Views and PresentingViews. 
- Make plain Views depend on their Props
- Make PresentingViews deal with Store and Presentaion logic.
  
  
```swift
 // some action
  
extension Actions {
    struct FetchFancyData: Action {

    }
}
  
```

Presenting view with explicit store:
  
```swift
  
struct FancyPresentingView: View {
    let store: PublishingStore<FancyFeatureState, Action>)
    
    var body: some View {
        FancyView.with(
            store: store,
            props: makeProps,
            content: { FancyView(props: $0) }
        )
    }
  
    func makeProps(
        state: FancyFeatureState, 
        store: PublishingStore<FancyFeatureState, Action>) -> FancyView.Props {
        
          FancyView.Props(
              title: state.title,
              onAppear: { store.dispatch(Actions.FetchFancyData()) }
          )
    }
}

```

Presenting view with implicit store:
  
```swift
struct FancyEnvPresentingView: View {
     
    var body: some View {
        FancyView.withEnvStore(
            props: makeProps,
            content: { FancyView(props: $0) }
        )
    }
  
    func makeProps(
        state: AppState, 
        store: PublishingStore<AppState, Action>) -> FancyView.Props {
        
          FancyView.Props(
              title: state.yourFancyFeatureSubstate.title,
              onAppear: { store.dispatch(Actions.FetchFancyData()) }
          )
    }
}

```
  
Presenting view that uses root env store and makes proxy from it  
  
```swift
struct FancyEnvSubstorePresentingView: View {
    @EnvironmentObject private var rootEnvStore: RootEnvStore<AppState, Action>
     
    var body: some View {
        FancyView.with(
            store: rootEnvStore.store().proxy { $0.yourFancyFeatureSubstate },
            props: makeProps,
            content: { FancyView(props: $0) }
        )
    }
  
    func makeProps(
        state: FancyFeatureState, 
        store: PublishingStore<FancyFeatureState, Action>) -> FancyView.Props {
        
          FancyView.Props(
              title: state.title,
              onAppear: { store.dispatch(Actions.FetchFancyData()) }
          )
    }
}

```
  

</p>
</details>

  


## Licensing

PureduxSwiftUI is licensed under MIT license.


