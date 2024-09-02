<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
  <img src="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
</picture>

Puredux is a lightweight UDF architecture framework in Swift.
  
<p align="left">
    <a href="https://github.com/KazaiMazai/Puredux/actions">
        <img src="https://github.com/KazaiMazai/Puredux/workflows/Tests/badge.svg" alt="Continuous Integration">
    </a>
</p>

## Features

Puredux is a minimal, yet powerful framework to build iOS applications in a clean and consistent way.

### State Store
- Minimal API
- Single/Multiple Stores Design
- Offloads work to the background
- Thread safety
- Side effects via actions interceptor
 
### SwiftUI & UIKit Bindings

SwiftUI & UIKit bindings to connect UI to Puredux Store

- Side-effects free SwiftUI Views
- Data-driven UIViewControllers
- Offloads heavy UI-related work to the background
- Takeover the control over state updates deduplication and UI refresh lifecycle

Check out the docs for more details:
- [PureduxSwiftUI Docs](Docs/PureduxSwiftUI.md)
- [PureduxUIKit Docs](Docs/PureduxUIKit.md)


## Installation

### Swift Package Manager.

Puredux is available through Swift Package Manager. 

To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/Puredux
```
 
## Migration Guiges

- [Migration Guides](Docs/Migration-Guides.md)


# Licensing

Puredux and all its modules are licensed under MIT license.



