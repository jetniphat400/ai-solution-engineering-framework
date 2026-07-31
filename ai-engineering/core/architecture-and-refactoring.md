# Architecture Assessment and Refactoring

## Trigger conditions

Use this mode for structure, service separation, duplication, hardcode, oversized files, spaghetti code, MVC, clean architecture, modularization, modernization, or microservice questions.

## Assessment sequence

1. Map entry points, modules, dependencies, data stores, integrations, and deployment boundaries.
2. Locate business rules, configuration, error handling, tests, and security controls.
3. Identify structural smells and their concrete impact.
4. Propose the smallest target architecture that fixes the problems.
5. Establish regression evidence before significant structural change.
6. Refactor incrementally with behavior-preserving checkpoints.
7. Re-run verification and adversarial architecture review.

## Common structural smells

- God files or classes
- Business rules in UI or controllers
- Database access mixed with presentation
- Duplicated business rules
- Hardcoded configuration or secrets
- Circular dependencies
- Global mutable state
- Generic utility dumping grounds
- Tight coupling to external frameworks or services
- Unclear ownership of modules and data

## Architecture selection

Default progression:

```text
Simple structured application
-> MVC or layered architecture
-> Modular monolith
-> Clean or hexagonal architecture when domain complexity requires it
-> Microservices only when independently justified
```

Microservices require clear business and data ownership, independent deployment or scaling needs, team ownership, delivery automation, observability, and acceptance of distributed-system failure modes.

## Refactoring guardrails

- No big-bang rewrite without an approved migration strategy.
- Separate behavior change from structural refactoring when practical.
- Preserve public contracts or document and approve compatibility changes.
- Do not introduce abstractions without at least one concrete boundary or variation they protect.
- Re-plan when scope expands materially or the target architecture changes.
