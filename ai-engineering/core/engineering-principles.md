# Engineering Principles

1. User outcome before solution preference.
2. Evidence before assumption.
3. Design before non-trivial implementation.
4. Simplicity before architecture fashion.
5. Small batches before large rewrites.
6. Existing valid patterns before new abstractions.
7. Explicit boundaries before shared mutable behavior.
8. Configuration before environment-specific hardcoding.
9. Verification evidence before completion claims.
10. Least privilege before autonomy.
11. Human approval before high-risk action.
12. Production feedback before declaring success.

## Code structure

- Give each module and file a clear responsibility.
- Keep controllers and UI thin; place business use cases in application or service layers.
- Keep domain rules independent of transport and persistence where complexity justifies it.
- Isolate database and external system access behind clear interfaces.
- Avoid cross-module reach-through and circular dependencies.
- Prefer domain names over generic `utils`, `helpers`, or `common` dumping grounds.

## Configuration

- Secrets belong in approved secret stores or environment injection.
- Environment-specific values belong in validated configuration.
- Legitimate domain constants belong in named constants or enums.
- Validate required configuration at startup and fail clearly.
