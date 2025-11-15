# Migrating to 2.2.x
 
Dependency Injection Migration to a standalone lib. Minor breaking changes

## Overview

- Dependency Injection was migrated to a standalone lib: [Crocodil](https://github.com/KazaiMazai/Crocodil)
- Macro has to be renamed

### SharedStores DI entry macro renamings

Macro `@StoreEntry` that was used for stores injection was renamed, `@DependencyEntry` should be used instead:

```diff
extension SharedStores {
-   @StoreEntry var rootState = StateStore<AppRootState, Action>(...) 
+   @DependencyEntry var rootState = StateStore<AppRootState, Action>(...)
}
```

