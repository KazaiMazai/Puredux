<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
  <img src="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
</picture>


<p align="left">
    <a href="https://github.com/KazaiMazai/Puredux/actions">
        <img src="https://github.com/KazaiMazai/Puredux/workflows/Tests/badge.svg" alt="Continuous Integration">
    </a>
</p>

Puredux is an architecture framework for SwiftUI and UIKit designed to
streamline state management with a focus on unidirectional data flow and separation of concerns.

- **Unidirectional MVI Architecture**: Supports a unidirectional data flow to ensure predictable state management and consistency.
- **SwiftUI and UIKit Compatibility**: Works seamlessly with both SwiftUI and UIKit, offering bindings for easy integration.
- **Single Store/Multiple Stores Design**: Supports both single and multiple store setups for flexible state management of apps of any size and complexity.
- **Separation of Concerns**: Emphasizes separating business logic and side effects from UI components.
- **Performance Optimization**: Offers granular performance tuning with state deduplication, debouncing, and offloading heavy UI-related work to the background.





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



