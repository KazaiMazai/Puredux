
## Puredux Monorepo Migration Guide

Puredux was refactored from a set of packages to a single monorepository.

These changes will require a few updates.

### 1. Change the package:

If you were using any of the packages individually:

- PureduxStore
- PureduxSwiftUI
- PureduxUIKit

You should update them to Puredux:

In Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repository URL:

```
https://github.com/KazaiMazai/Puredux
```

Remove the individual repositories:

```
- https://github.com/KazaiMazai/PureduxUIKit
 
- https://github.com/KazaiMazai/PureduxSwiftUI
  
- https://github.com/KazaiMazai/PureduxStore
```

### 2. Fix imports:

Find and relace all the occurences of:

```swift
import PureduxSwiftUI
```

```
import PureduxUIKit
```

```
import PireduxStore

```

on 

```swift
import Puredux

```
