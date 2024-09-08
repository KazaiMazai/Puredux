# Migrating to 1.2.x

Puredux was refactored from a set of packages to a single monorepository.

These changes will require a few updates.

## Change the Package

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
1. https://github.com/KazaiMazai/PureduxUIKit
2. https://github.com/KazaiMazai/PureduxSwiftUI
3. https://github.com/KazaiMazai/PureduxStore
```

## Fix Imports

Find and replace all the occurences:

```diff
- import PureduxSwiftUI
- import PureduxUIKit
- import PireduxStore

+ import Puredux

```
