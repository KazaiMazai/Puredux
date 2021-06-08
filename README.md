# Puredux

Puredux is a lightweight UDF architecture framework in Swift.


## What's Puredux

Purderux is a minimalistic, but yet poweful library that allows to build iOS application in a clean and consistent way.

- It's tiny and easy to use and understand.
- It's modular. Allows to bring to a project only those depenencies it's really need.
- It's flexible enough to be as strict as you want.

## Why Puredux

- Separate the State from the rest of the app
- The most fresh State delivery.
- No room for unexpected state mutations.
- Independent State-driven side effects. 


## What's it made of

<p align="center">
  <img src="Scheme.svg?raw=true" alt="Sublime's custom image"/>
</p>



Puredux has 3 main domains:

- State
- Actions
- Store
- Store Observers
- Side Effects
- UI binding

### State 
State is supposed to be data struct, representing the state of the whole app, while the rest of the app is supposed to be at most stateless.

### Actions
Actions work like transactions describing all events that happen in the app. 

### Reducer

Reducer is simply a function, that is supposes to perform mutations on the state, taking current state and action as an input.

### Store

Store is the heart of the whole thing. Taking initial state and reducer as an input, it mutatees the state when new Actions are dispatched to it.
New state is eventually delivered to its observers.

Basic implementation of Store and Observers can be found here: [PureduxStore](https://github.com/KazaiMazai/PureduxStore)
 
## Side Effects
Side Effects is all the async work the app performs. In Puredux side effects are supoosed to be state-driven. So the app performs excatly those side effects that are defined by state in any moment of time.


In Puredux, all side effects are handled by means of 

- Operators 
- Side Effects state mapping
- Middleware 

### Operator   

Puredux's Operator typically has an input of an array of requests.
It always tries to match its input and the work it performs.

So it performs only those requests that we pass to it and cancels all the rest. 

Implementation of SideEffect and Base Operator: [PureduxSideEffects](https://github.com/KazaiMazai/PureduxSideEffects)

Operator wrapper around URLSession to perform network requests: [PureduxNetworkOperator](https://github.com/KazaiMazai/PureduxNetworkOperator)

### Side Effects state mapping

To make it all flexible Puredux provides SideEffects struct allows to defined how the AppState should be mapped into Operators' Requests.

### Middleware

Middleware is a glue to combine Operator and SideEffecrs state mapping together and subscribe that thing to a Store.

## PureduxSwiftUI

PureduxSwiftUI provides a way to subscribe SwiftUI views to the Store without exposing internal details related to state changes delivery.
It makes SwiftUI very clean and consitent.

To make SwiftUI View work with Puredux it should simply conform to PresentableView protocol.

PureduxSwiftUI implementation can be found here: [PureduxSwiftUI](https://github.com/KazaiMazai/PureduxSwiftUI)

## PureduxUIKit

PureduxSwiftUI provides a way to connect good old UIViewControllers to the store. To connect it, UIViewController should conform to PresentableViewController
and call connect method, that allows to bind Store with it, using specified presenter.

PureduxUIKit implementation can be found here: [PureduxUIKit](https://github.com/KazaiMazai/PureduxUIKit)

# PureduxDemoApp

Demo app implementation with Network, State Persistance and clean SwiftUI views can be found here:

[PureduxDemoApp (https://github.com/KazaiMazai/PureduxDemo)



