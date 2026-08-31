---
name: developing-gradle-plugins
description: Use when creating, reviewing, testing, or refactoring Gradle plugins written in Kotlin, including Project, Settings, or init-script plugins; public DSL and task APIs; Provider or ValueSource wiring; Configuration Cache and isolated projects; cross-project artifacts; build services; Worker API; Problems API; FlowAction; and Gradle TestKit tests.
---

# Developing Gradle Plugins

## Baseline

- Created against: Gradle 9.7.0
- Language: Kotlin
- Project type: standalone `java-gradle-plugin`
- Core rule: keep configuration lazy and target-owned; put execution in tasks, workers, services, or flow actions; exchange project data through declared providers and configurations.

## Workflow

1. Identify the plugin target and supported public surface.
2. Read every page relevant to the change.
3. Design providers and configuration roles before registering tasks.
4. Keep project configuration isolated.
5. Choose the smallest execution primitive that fits.
6. Test pure logic, Gradle model configuration, and real builds.

## Page index

| Need | Read |
|---|---|
| Plugin targets, marker registration, external plugin dependencies | [Plugin structure](references/plugin-structure.md) |
| DSL, task, configuration, visibility, package, and naming contracts | [Plugin API design](references/plugin-api-design.md) |
| Provider wiring, external inputs, configuration avoidance, logging | [Configuration and wiring](references/configuration-and-wiring.md) |
| Tasks, CLI options, workers, verification failures, Problems API, `FlowAction` | [Implementing tasks](references/implementing-tasks.md) |
| Settings defaults, project extras, artifact sharing, build services | [Cross-project communication](references/cross-project-communication.md) |
| Unit tests, `ProjectBuilder`, TestKit, local publication | [Testing](references/testing.md) |
| Organisation-specific overrides | [Technoir Lab conventions](references/technoir-lab-conventions.md) |

## Common mistakes

| Mistake | Route |
|---|---|
| Eager provider reads or task creation | [Configuration and wiring](references/configuration-and-wiring.md) |
| Cross-project model access | [Cross-project communication](references/cross-project-communication.md) |
| Gradle-managed logic that cannot be unit tested | [Testing](references/testing.md) |

## References

- [Best Practices Index](https://docs.gradle.org/current/userguide/best_practices_index.html)
- [Public Gradle APIs](https://docs.gradle.org/current/userguide/public_apis.html)
- [Gradle User Manual](https://docs.gradle.org/current/userguide/userguide.html)
