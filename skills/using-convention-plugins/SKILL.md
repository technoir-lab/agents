---
name: using-convention-plugins
description: Apply Technoir Lab conventions when creating, editing, or reviewing build configuration, library choices, logging, dependencies, tests, serialization, or publishing in projects applying any io.technoirlab.conventions.* Gradle plugin.
---

# Using Convention Plugins

## Scope

- Do not apply `io.technoirlab.conventions.common` directly; it is an internal implementation plugin.
- Use the convention's public DSL and supplied tasks for functionality it owns.
- Match guidance to the project's convention-plugin version; consult implementation and public APIs when README examples disagree.

## Workflow

1. Identify applied convention plugins and their version, including aliases and shared build logic.
2. For library choices, read the [tech stack](references/tech-stack.md); select other relevant pages below and apply their rules using the platform tags.
3. Apply the [build-feature rules](references/build-features.md#shared-feature-switches) when configuring module features.
4. Validate changes with the existing tasks relevant to the changed behavior.

## Platform tags

| Tag | Applies to |
|---|---|
| no tag | Any project within this skill's scope |
| `[JVM]` | JVM code and targets, including JVM source sets in KMP projects; exclude common and non-JVM source sets |
| `[KMP]` | Kotlin Multiplatform projects only; exclude regular JVM projects |
| `[Gradle]` | Gradle plugin development: plugin source code, public DSL/API, tests, and plugin-module configuration |

- Tags on headings apply to the entire section; tags on rows or bullets further narrow that scope.
- Combined tags require all listed scopes; module-specific conditions still apply.
- Leave general build configuration rules untagged; version catalogs, shared feature switches, and project setup apply across project types.

## Page index

| Need | Read |
|---|---|
| Library choices by category and project scope | [Tech stack](references/tech-stack.md) |
| Plugin selection, DSL names, settings, coordinates, JVM execution | [Project setup](references/project-setup.md) |
| Direct dependencies, API exposure, version catalogs, serialization | [Dependencies and serialization](references/dependencies-and-serialization.md) |
| ABI validation, BuildConfig, redaction, optional feature defaults | [Build features](references/build-features.md) |
| JUnit, KMP tests, fixtures, lint, coverage, dependency analysis | [Testing and quality](references/testing-and-quality.md) |
| Public plugin APIs, Gradle compatibility, TestKit integration | [Gradle plugin modules](references/gradle-plugin-modules.md) |
| KMP targets, benchmarks, Metro, C interop, Native/Wasm binaries | [Multiplatform projects](references/multiplatform.md) |
| Maven Central or Maven Local publication, project metadata, API documentation | [Publishing and documentation](references/publishing.md) |

## References

- [Convention plugins EditorConfig](https://github.com/technoir-lab/convention-plugins/blob/main/.editorconfig)
- [Tech stack library references](references/tech-stack.md#references)
- [Kotlin code style: Platform tag conventions](../kotlin-code-style/SKILL.md#platform-tags)
- [Technoir Lab convention plugins repository](https://github.com/technoir-lab/convention-plugins)
