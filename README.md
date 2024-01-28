<p align="center">
  <img src="Logo.svg?raw=true" alt="Sublime's custom image"/>
</p>

# Puredux

Puredux is a lightweight MVI architecture framework in Swift.

## What's Puredux

Purderux is a minimal, yet poweful library that allows to build iOS application in a clean and consistent way.

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

Puredux hides all async stuff under the hood, leaving only sync things on the surface. Making app layers thin, plain and testable as hell.

# Installation


## Swift Package Manager.

Puredux is available through Swift Package Manager. 
To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/Puredux
```

## Puredux-Store

- Minimal API
- Single/Multiple Stores
- Operates on background queue
- Thread safe stores
- Simple actions interceptor for side effects

## PureduxSwiftUI

SwiftUI bindings to connect UI to PureduxSrore

- Сlean and reusable SwiftUI's Views without dependencies
- Presentation data model aka. 'Props' can be prepared on Main or Background queue
- State updates deduplication to avoid unnecessary UI refresh

## PureduxUIKit

UIKit bindings to connect UI to PureduxStore

- Clear path to data-driven UIViewControllers
- Presentation data model aka. 'Props' can be prepared on Main or Background queue
- State updates deduplication to avoid unnecessary UI refresh

# Licensing

Puredux and all its modules are licensed under MIT license.



