# Engineering Principles

Relevance: include this file for most software projects. It defines shared design and implementation principles for humans and agents.

## Why this file exists

This module explains the reasoning style that should guide engineering decisions when project-specific rules are incomplete or ambiguous.

## How to apply these principles

- Use principles as decision heuristics, not rigid laws.
- When principles conflict, prioritize user-visible correctness and long-term maintainability.
- If a change increases complexity, state why the complexity is necessary.

## Principles

### Keep It Simple

Prefer the simplest implementation that satisfies current requirements.

Signals of over-engineering:
- abstractions introduced without repeated need
- generic frameworks created for one-off behavior

### Build What Is Needed

Do not implement speculative flexibility.

Practical use:
- delay optional abstraction until concrete reuse appears
- default to tighter visibility and narrower APIs

### Avoid Duplication Thoughtfully

Reduce duplicated behavior when it lowers defects and maintenance cost.

Practical use:
- deduplicate business logic before presentation details
- avoid abstractions that hide intent across unrelated contexts

### Single Source of Truth

Keep authoritative mutable state in one place and derive everything else.

### Make Invalid States Hard to Represent

Use types, enums, and constrained interfaces to prevent illegal states.

### Explicit Dependencies

Prefer constructor or parameter injection over hidden globals.

### Composition Over Inheritance

Prefer small composable types and protocol boundaries to deep hierarchies.

### Separate Commands From Queries

Avoid methods that both mutate state and return complex derived outputs.

### Least Knowledge

Minimize coupling by avoiding deep dependency chains and leaky boundaries.

### Concurrency by Design

Be explicit about actor/threading boundaries and shared mutable state ownership.

## Decision Heuristics

When unsure:
- prioritize correctness and safety over micro-optimization
- prefer local changes over broad refactors
- keep public surface area intentionally small
- align with established project patterns unless there is strong reason to diverge

## Guidance for Agent Outputs

- Keep diffs focused and easy to review.
- Briefly explain architectural tradeoffs when changing structure.
- If adding abstraction, name the concrete duplication or risk it resolves.
