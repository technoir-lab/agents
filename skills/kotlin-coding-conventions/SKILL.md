---
name: kotlin-coding-conventions
description: Apply Technoir Lab Kotlin coding conventions when creating or editing Kotlin source files (.kt) or Kotlin scripts (.kts) in Technoir Lab projects.
---

# Kotlin Coding Conventions

## Baseline

- Base Technoir Lab code style on the official Kotlin style guide listed in [References](#references).
- Use Technoir Lab rules to clarify, extend, or override the official guide.

## Workflow

1. Read [style rules](references/rules.md) before creating or editing Kotlin files.
2. When creating or editing tests, also read [test style rules](references/tests.md).
3. When using kotlinx.serialization, also read [kotlinx.serialization rules](references/kotlinx-serialization.md).
4. When working with closeable resources, files, URLs, or Java serialization, also read [I/O rules](references/io.md).
5. Apply the official guide and Technoir Lab rules to the Kotlin code being created or edited, using the [platform tags](#platform-tags) to select applicable rules.
6. Check the resulting changes against the rules and their examples.

## Platform tags

| Tag        | Applies to                                                                                                   |
|------------|--------------------------------------------------------------------------------------------------------------|
| no tag     | any Kotlin project                                                                                           |
| `[Android]` | Android projects                                                                                           |
| `[JVM]`    | JVM code, including JVM source sets in Kotlin Multiplatform projects; exclude common and non-JVM source sets |
| `[KMP]`    | Kotlin Multiplatform projects only; exclude regular JVM projects                                             |
| `[Gradle]` | Source code of Gradle plugins and Kotlin build scripts (*.kts)                                               |

## Page index

| Need | Read |
|---|---|
| Style rules with incorrect and correct Kotlin examples | [Style rules](references/rules.md) |
| Test naming, body structure, assertions, annotation order, and code snippets | [Test style rules](references/tests.md) |
| kotlinx.serialization models, JSON configuration, and file I/O | [kotlinx.serialization rules](references/kotlinx-serialization.md) |
| Closeable resources, file paths, URLs, and Java serialization | [I/O rules](references/io.md) |

## References

- [Official Kotlin style guide: Coding conventions](https://kotlinlang.org/docs/coding-conventions.html)
