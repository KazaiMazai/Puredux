<p align="center">
  <img src="Logo.svg?raw=true" alt="Sublime's custom image"/>
</p>

# Puredux

Puredux is a lightweight UDF architecture framework in Swift.


## What's Puredux

Purderux is a minimalistic, but yet poweful library that allows to build iOS application in a clean and consistent way.

- It's tiny and easy to use and understand
- It's modular. Allows to bring to a project only those depenencies that it really needs
- It's flexible enough to be as strict as you want

## Why Puredux

- Pure state and reducer without side effects
- Clean UI and Presentation layer
- No room for unexpected state mutations
- All async work under control
- Another level of testability with independent side effects


## Special features

### Pure state

Modelling app state as a codable struct allows to obtain persistance out of the box.


### Threading
Puredux tries to make as little load on the MainThread's queue as possible.
PureduxStore is threadsafe and performs dispatching and then reduces the state on a background queue.

By defaut, Puredux presenters would prepare views' props in background as well.

Puredux hides alland async stuff under the hood, leaving only sync things on the surface. Making app layers thin, plain and testable as hell.


## What is it made of

<p align="center">
  <img src="Scheme.svg?raw=true" alt="Sublime's custom image"/>
</p>


## Core
### State

State is supposed to be data struct, representing the state of the whole app, while the rest of the app is supposed to be at most stateless.

### Actions

Actions represent all events that happen in the app. 

## Store
### Reducer 

Reducer is simply a function, that is supposes to perform mutations on the state, taking current state and action as an input.

### Store & Observers

Store is the heart of the whole thing. Taking initial state and reducer as an input, it mutatees the state when new Actions are dispatched to it.
New state is eventually delivered to its observers.

Basic implementation of Store and Observers can be found here: [PureduxStore](https://github.com/KazaiMazai/PureduxStore)
 
## UI Layer

### View Props

Props are the views' input data structs, describing view's state entirely.

### Presenters

Presenters prepares Props for the views.  

### PureduxSwiftUI

PureduxSwiftUI provides a way to subscribe SwiftUI views to the Store without exposing internal details related to state changes delivery.
It makes SwiftUI very clean and consitent.

To make SwiftUI View work with Puredux it should simply conform to **PresentableView** protocol.

PureduxSwiftUI implementation can be found here: [PureduxSwiftUI](https://github.com/KazaiMazai/PureduxSwiftUI)

### PureduxUIKit

PureduxUIKit provides a way to bind good old UIViewControllers to the store. 

To make it work UIViewController should conform to **PresentableViewController** protocol
and call connect method, that allows to bind Store with it, using specified presenter.

PureduxUIKit implementation can be found here: [PureduxUIKit](https://github.com/KazaiMazai/PureduxUIKit)


## Side Effects
Side Effects is all the async work the app performs. In Puredux side effects are supoosed to be state-driven. So the app performs excatly those side effects that are defined by state in any moment of time.

In Puredux, all side effects are handled by means of 

- Operators 
- Side Effects state mapping
- Middleware 

### Operator 

Puredux's Operator typically has an input of an array of requests.
It always tries to match the work it performs to its inputs.

That means that Operator performs only those requests that we pass to it and cancels all the rest. 

Implementation of SideEffect and Base Operator: [PureduxSideEffects](https://github.com/KazaiMazai/PureduxSideEffects)

Operator wrapper around URLSession to perform network requests: [PureduxNetworkOperator](https://github.com/KazaiMazai/PureduxNetworkOperator)

### Side Effects state mapping

To make it all flexible Puredux provides SideEffects struct allows to defined how the AppState should be mapped into Operators' Requests.

### Middleware

Middleware is a glue to combine Operator and SideEffecrs state mapping together and subscribe that thing to a Store.


# Installation
 

## Swift Package Manager.

Puredux is available through Swift Package Manager. 
To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

#### Puredux
Base package, that includes PureduxStore, PureduxSideEffects, PureduxNetworkOperator
```
https://github.com/KazaiMazai/Puredux
```
#### PureduxSwiftUI

Puredux SwiftUI bindings

```
https://github.com/KazaiMazai/PureduxSwiftUI
```

#### PureduxUIKit

Puredux UIKit bindings

```
https://github.com/KazaiMazai/PureduxSwiftUI
```

#### PureduxCommonOperators

Puredux commonly used operators implementation

```
https://github.com/KazaiMazai/PureduxCommonOperators
```
#### PureduxCommonCore

Puredux commonly used state components implementation

```
https://github.com/KazaiMazai/PureduxCommonOperators
```

# PureduxDemoApp

Demo app implementation with Network, State Persistance and clean SwiftUI views can be found here:

[PureduxDemoApp](https://github.com/KazaiMazai/PureduxDemo)

# Licensing

Puredux and all its modules are licensed under MIT license.



