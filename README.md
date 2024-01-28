<p align="center">
  <img src="Logo.svg?raw=true" alt="Sublime's custom image"/>
</p>

# Puredux

Puredux is a lightweight MVI architecture framework in Swift.

## Features

- Tiny and easy to use and understand
- Pure state and reducer without side effects
- Clean UI and Presentation layer
- No room for unexpected state mutations
- All async work under control

Puredux is a minimal, yet poweful framework that allows to build iOS application in a clean and consistent way.

# Installation

## Swift Package Manager.

Puredux is available through Swift Package Manager. 

To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/Puredux
```

# Basics

## PureduxStore

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
- Presentation data models aka. 'Props' can be prepared on Main or Background queue
- State updates deduplication to avoid unnecessary UI refresh

## Check out the Docs for more details:
 
- [PureduxUIKit](Docs/PureduxStore.md)
- [PureduxUIKit](Docs/PureduxSwiftUI.md)
- [PureduxUIKit](Docs/PureduxUIKit.md)

# Licensing

Puredux and all its modules are licensed under MIT license.



