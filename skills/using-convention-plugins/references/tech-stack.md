# Tech Stack

- Select libraries by category and project scope below.
- Keep optional features opt-in; use the linked setup instructions when the module needs them.
- Follow [version catalog rules](dependencies-and-serialization.md#version-catalogs) when declaring dependencies.

## Browser APIs

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [KMP] Browser APIs in JS and WasmJS source sets, including shared browser source sets | kotlinx-browser | `org.jetbrains.kotlinx:kotlinx-browser` | Project: declare explicitly |

## Command-line interfaces

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| Implementing command-line commands, arguments, and options | Clikt | `com.github.ajalt.clikt:clikt` | Project: declare explicitly |

## Concurrency

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| Asynchronous and concurrent operations | kotlinx.coroutines | `org.jetbrains.kotlinx:kotlinx-coroutines-core` | Convention-supplied coroutines BOM |

## Databases

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| SQLite persistence in KMP, JVM, and Gradle plugin projects | Room 3 | `androidx.room3:room3-runtime`, `androidx.room3:room3-compiler` (KSP processor) | Project: declare a shared Room version |
- Add the Room compiler to the applicable KSP configurations; the module conventions already apply KSP.
- Configure a SQLite driver appropriate to each target; follow the [Room 3 setup documentation](https://developer.android.com/jetpack/androidx/releases/room3).

## Date and time

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [KMP] All targets, including JVM | kotlinx-datetime | `org.jetbrains.kotlinx:kotlinx-datetime` | Project: declare explicitly |
| [JVM] Regular JVM application/library projects | `java.time` APIs with Kotlin standard-library extensions from `kotlin.time` | JDK and `org.jetbrains.kotlin:kotlin-stdlib` (already available; no additional dependency) | Java toolchain and convention-supplied Kotlin BOM |
| [Gradle] Gradle plugin projects | `java.time` APIs with Kotlin standard-library extensions from `kotlin.time` | JDK and `org.jetbrains.kotlin:kotlin-stdlib` (already available; no additional dependency) | Java toolchain and convention-supplied Kotlin BOM |

## Gradle plugin development

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [Gradle] Reusable helpers for plugin implementation | Technoir Lab Gradle extensions | `io.technoirlab.conventions:gradle-extensions` | Convention dependency resolution |
| [Gradle] Test-project fixtures and Gradle runner helpers for functional tests | Technoir Lab Gradle test helpers | `io.technoirlab.conventions:gradle-test-kit` | Convention dependency resolution |

- Versionless libraries in `io.technoirlab.conventions` resolve to the applied convention's version.
- [Gradle] Add `gradle-test-kit` to `functionalTestImplementation`; it supplements Gradle's own TestKit dependency already supplied to the [functional test suite](gradle-plugin-modules.md#gradle-functional-tests).

## I/O

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [KMP] All targets, including JVM | kotlinx-io | `org.jetbrains.kotlinx:kotlinx-io-core` | Project: declare explicitly |
| [JVM] Regular JVM application/library projects | Java NIO with Kotlin `kotlin.io.path` extensions | JDK and `org.jetbrains.kotlin:kotlin-stdlib` (already available; no additional dependency) | Java toolchain and convention-supplied Kotlin BOM |
| [Gradle] Gradle plugin projects | Java NIO with Kotlin `kotlin.io.path` extensions | JDK and `org.jetbrains.kotlin:kotlin-stdlib` (already available; no additional dependency) | Java toolchain and convention-supplied Kotlin BOM |

## Logging

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [KMP] All targets, including JVM | [kotlin-logging](https://github.com/oshai/kotlin-logging) | `io.github.oshai:kotlin-logging` | Project: declare explicitly |
| [JVM] Regular JVM application/library projects | SLF4J 2.x | `org.slf4j:slf4j-api`, `org.slf4j:slf4j-simple` | Project: declare a shared SLF4J version |
| [Gradle] Gradle plugin projects | Gradle's `org.gradle.api.logging.Logger`, which extends SLF4J's logger API | Provided by the Gradle API | Gradle runtime |

- [Gradle] Reuse Gradle's logging implementation; do not add a separate logging facade or provider to plugin code.

## HTTP

| Implementation | Use | Dependencies | Version supplied by |
|---|---|---|---|
| HTTP client | Ktor with the CIO engine | `io.ktor:ktor-bom`, `io.ktor:ktor-client-core`, `io.ktor:ktor-client-cio` | Ktor BOM: project declares the BOM version |
| HTTP server | Ktor with the CIO engine | `io.ktor:ktor-bom`, `io.ktor:ktor-server-core`, `io.ktor:ktor-server-cio` | Ktor BOM: project declares the BOM version |

## Serialization

| Format | Use | Dependencies | Version supplied by |
|---|---|---|---|
| Any | kotlinx.serialization core APIs | `org.jetbrains.kotlinx:kotlinx-serialization-core` | Convention-supplied serialization BOM |
| JSON | kotlinx.serialization JSON | `org.jetbrains.kotlinx:kotlinx-serialization-json` | Convention-supplied serialization BOM |
| YAML | kotlinx.serialization with kotaml | `io.heapy.kotaml:kotaml` | Project: declare explicitly |

- Configure the compiler feature and dependencies using [serialization setup](dependencies-and-serialization.md#serialization).

## Testing

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [KMP] All targets, including JVM | `kotlin-test` test framework | `org.jetbrains.kotlin:kotlin-test` | Convention-supplied Kotlin BOM |
| [JVM] Regular JVM application/library projects | JUnit 6 | `org.junit.jupiter:junit-jupiter` (provided by conventions) | Convention test-suite configuration |
| [Gradle] Gradle plugin projects | JUnit 6 | `org.junit.jupiter:junit-jupiter` (provided by conventions) | Convention test-suite configuration |
| Tests of suspending functions and coroutine behavior in any project | kotlinx.coroutines test utilities: `runTest` and virtual-time scheduling | `org.jetbrains.kotlinx:kotlinx-coroutines-test` | Convention-supplied coroutines BOM |

- [KMP] Use `kotlin.test` test annotations in both common and target-specific test source sets; do not introduce direct JUnit dependencies or imports for KMP JVM tests.
- Follow [test setup and fixture rules](testing-and-quality.md) for dependency and source-set wiring.
- Declare `kotlinx-coroutines-test` in test source sets only.

### Assertions

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [KMP] All targets, including JVM | AssertK | `com.willowtreeapps.assertk:assertk` | Project: declare explicitly |
| [JVM] Regular JVM application/library projects | AssertJ | `org.assertj:assertj-core` | Project: declare explicitly |
| [Gradle] Gradle plugin projects | AssertJ | `org.assertj:assertj-core` | Project: declare explicitly |

## Dependency injection

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [KMP] Optional dependency injection | Metro | `dev.zacsweers.metro:runtime` (provided when enabled) | Convention-applied Metro plugin |

- Follow [KMP feature setup](multiplatform.md#kmp-optional-features).

## Benchmarking

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| [KMP] Optional performance benchmarks | kotlinx.benchmark | `org.jetbrains.kotlinx:kotlinx-benchmark-runtime` (provided when enabled) | Convention benchmark configuration |

- Follow [KMP feature setup](multiplatform.md#kmp-optional-features).

## Redaction

| When | Use | Dependencies | Version supplied by |
|---|---|---|---|
| Generated data-class `toString()` output must redact sensitive values | Redacted compiler plugin | `dev.zacsweers.redacted:redacted-compiler-plugin-annotations` (provided by default when enabled) | Convention-applied Redacted plugin |

- Follow [shared feature setup](build-features.md#shared-feature-switches).

## References

- [Convention JUnit version and test-suite configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Testing.kt)
- [JVM compiler, BOM, and ABI configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Kotlin.kt)
- [KMP targets, hierarchy, BOMs, ABI, and C interop](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/configuration/KotlinMultiplatform.kt)
- [Technoir Lab: Gradle extension helpers](https://github.com/technoir-lab/convention-plugins/tree/main/libraries/gradle-extensions)
- [Technoir Lab: Gradle test helpers](https://github.com/technoir-lab/convention-plugins/tree/main/libraries/gradle-test-kit)
- [Convention dependency default-version resolution](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Common.kt)
- [kotlinx-browser: Browser targets and dependencies](https://github.com/Kotlin/kotlinx-browser)
- [Room 3: Dependencies, KSP, and platform support](https://developer.android.com/jetpack/androidx/releases/room3)
- [kotlinx.coroutines: Coroutine test utilities](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-test/)
- [kotlinx-datetime: Usage and dependencies](https://github.com/Kotlin/kotlinx-datetime)
- [Kotlin standard library: Time APIs and Java time conversions](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.time/)
- [Kotlin standard library: Java Duration conversion extension](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.time/to-kotlin-duration.html)
- [kotlinx-io: Usage and dependencies](https://github.com/kotlin/kotlinx-io)
- [Kotlin standard library: Java NIO Path extensions](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.io.path/)
- [Clikt: Installation and multiplatform support](https://github.com/ajalt/clikt)
- [kotlinx.coroutines: Usage and dependencies](https://github.com/Kotlin/kotlinx.coroutines)
- [Ktor: BOM version alignment](https://ktor.io/docs/client-dependencies.html#using-the-ktor-bom-dependency)
- [AssertK: Setup and multiplatform support](https://github.com/assertk-org/assertk)
- [AssertJ Core: Quick start](https://assertj.github.io/doc/#assertj-core-quick-start)
- [kotlin-logging: Publishing configuration](https://raw.githubusercontent.com/oshai/kotlin-logging/master/build.gradle.kts)
- [Metro: Installation and runtime dependency](https://zacsweers.github.io/metro/latest/installation/)
- [kotlinx.benchmark: Setup and runtime dependency](https://github.com/Kotlin/kotlinx-benchmark)
- [Redacted compiler plugin: Installation](https://github.com/ZacSweers/redacted-compiler-plugin)
- [Maven Central: Redacted annotations coordinates](https://central.sonatype.com/artifact/dev.zacsweers.redacted/redacted-compiler-plugin-annotations)
- [Ktor: Client engines](https://ktor.io/docs/client-engines.html)
- [Ktor: Server engines](https://ktor.io/docs/server-engines.html)
- [kotlin-logging repository](https://github.com/oshai/kotlin-logging)
- [SLF4J manual: API and version 2.x](https://www.slf4j.org/manual.html)
- [Gradle API: Logger](https://docs.gradle.org/current/javadoc/org/gradle/api/logging/Logger.html)
- [kotlinx.serialization guide](https://github.com/Kotlin/kotlinx.serialization/blob/master/docs/serialization-guide.md)
- [kotaml: YAML support and supported targets](https://github.com/Heapy/kotaml)
- [Kotlin test API](https://kotlinlang.org/api/core/kotlin-test/)
- [JUnit 6 user guide: Overview](https://docs.junit.org/6.1.3/overview.html)
- [Gradle API variant and functional test configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/configuration/Plugin.kt)
- [Metro feature wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/configuration/Metro.kt)
- [KMP benchmark configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/configuration/Benchmarking.kt)
- [Redacted feature wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Redacted.kt)
