# Engineering Principles

1. User outcome before solution preference. [established practice — Jobs-to-be-Done / 5-Whys: solve the underlying need, not the first proposed solution]
2. Evidence before assumption. [established practice — empirical software engineering / the scientific method applied to claims about a codebase]
3. Design before non-trivial implementation. [established practice — structured design discipline predating and surviving Agile: plan the shape of non-trivial work before writing it]
4. Simplicity before architecture fashion. [established practice — KISS / YAGNI, Extreme Programming]
5. Small batches before large rewrites. [established practice — Agile / XP small-batch delivery]
6. Existing valid patterns before new abstractions. [established practice — "Rule of Three" / avoid premature abstraction, Fowler]
7. Explicit boundaries before shared mutable behavior. [established practice — information hiding, Parnas 1972]
8. Configuration before environment-specific hardcoding. [established practice — externalized configuration, the Twelve-Factor App]
9. Verification evidence before completion claims. [established practice — TDD / Definition of Done]
10. Least privilege before autonomy. [established practice — Saltzer & Schroeder]
11. Human approval before high-risk action. [established practice — change-management approval gates]
12. Production feedback before declaring success. [established practice — DevOps/SRE feedback loop: production observation closes the loop, not the last green check]

## Code structure

[established practice — separation of concerns / SOLID, applied here as: single-responsibility modules, thin controllers (layered/MVC architecture), transport-independent domain rules (hexagonal / clean architecture, Domain-Driven Design), dependency inversion for external access, and the Law of Demeter against reach-through coupling]

- Give each module and file a clear responsibility.
- Keep controllers and UI thin; place business use cases in application or service layers.
- Keep domain rules independent of transport and persistence where complexity justifies it.
- Isolate database and external system access behind clear interfaces.
- Avoid cross-module reach-through and circular dependencies.
- Prefer domain names over generic `utils`, `helpers`, or `common` dumping grounds.

## Configuration

[established practice — the Twelve-Factor App's config-in-environment principle, extended with OWASP secrets-management guidance for the secrets bullet]

- Secrets belong in approved secret stores or environment injection.
- Environment-specific values belong in validated configuration.
- Legitimate domain constants belong in named constants or enums.
- Validate required configuration at startup and fail clearly.
