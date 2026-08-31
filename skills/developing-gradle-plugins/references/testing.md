# Testing

## Test taxonomy

Use two kinds of tests: unit and functional.

| Kind | Subtype | Tooling | Boundary |
|---|---|---|---|
| Unit | Pure unit | Kotlin/JVM + JUnit 6 | Standard types; stub Gradle-managed interfaces |
| Unit | Gradle model | `ProjectBuilder` + JUnit 6 | Apply plugins, create managed types, inspect configuration; do not execute tasks |
| Functional | Real build | TestKit `GradleRunner` + JUnit 6 | Execute builds, tasks, plugin application, and dependency resolution |

## Unit-testable design

- Extract pure policy, parsing, validation, protocol, and transformation logic from `Plugin`, `Task`, `BuildService`, and `WorkAction` implementations.
- Keep Gradle implementations as thin adapters from managed properties to pure functions.
- Stub small Gradle-managed interfaces only at the pure boundary.
- Use `ProjectBuilder` when Gradle must create the managed object or model.
- Do not attempt task execution with `ProjectBuilder`.
- Pair a consumer-supplied plugin's `compileOnly` dependency with a matching `testRuntimeOnly` or `testImplementation` dependency when a unit or model test applies or inspects that plugin.

```kotlin
internal class ExampleBuildLogic {
    fun generate(inputFile: File, outputFile: File) {
        outputFile.writeText(inputFile.readText().uppercase())
    }
}

class ExampleBuildLogicTest {
    private val exampleBuildLogic = ExampleBuildLogic()

    @Test
    fun `generates uppercase output`(@TempDir tempDir: File) {
        val inputFile = tempDir.resolve("input.txt").apply {
            writeText("Hello, world")
        }
        val outputFile = tempDir.resolve("output.txt")

        exampleBuildLogic.generate(inputFile, outputFile)

        assertEquals("HELLO, WORLD", outputFile.readText())
    }
}
```

## Functional-test publication contract

Do not use `withPluginClasspath()`.

1. Apply `maven-publish` to the plugin project.
2. Make the functional-test task depend on `publishToMavenLocal`.
3. Use a unique test publication GAV and pass it into generated fixture text through declared test inputs.
4. Add `mavenLocal()` to `pluginManagement.repositories` in the fixture settings file.
5. Apply the published plugin by ID and version.
6. Run the fixture with `GradleRunner`.

```kotlin
val buildResult = GradleRunner.create()
    .withProjectDir(testProjectDir)
    .withArguments("verifyMetadata", "--stacktrace")
    .forwardOutput()
    .build()

val result = buildResult.task(":verifyMetadata")?.outcome

assertEquals(TaskOutcome.SUCCESS, result)
```

### Init-plugin fixture

Put the published implementation artifact on the init-script classpath, then apply its generated plugin descriptor by ID:

```kotlin
initscript {
    repositories {
        mavenLocal()
    }
    dependencies {
        classpath("com.example:example-plugin:test-fixture")
    }
}

apply(plugin = "com.example.plugin.init")
```

Pass the script to `GradleRunner` with `--init-script`; do not use `pluginManagement` for Init plugins.

## Functional matrix

- Plugin marker resolution from `mavenLocal()`
- Project, Settings, and init plugin application
- Plugin dependency application order
- Task execution, CLI options, failures, outputs, and dependency resolution
- Repeated-build state and input invalidation boundaries
- Task cacheability and Build Cache relocation across project directories
- Global settings defaults and per-project overrides
- Variant-aware producer/consumer artifacts
- Shared service reuse and `close()` behavior
- Configuration Cache store and reuse
- Isolated Projects with multiple projects
- Parallel task execution and worker isolation
- Missing inputs, invalid DSL, and structured problems
- Host-specific behavior guarded with JUnit assumptions

## Common mistakes

| Mistake | Correction |
|---|---|
| Gradle-heavy logic in every unit test | Extract pure logic and keep adapters thin |
| Calling task actions from a unit test | Exercise the task through TestKit |
| `withPluginClasspath()` bypasses publication | Publish and resolve through `mavenLocal()` |
| Only testing successful configuration | Cover execution, resolution, failures, cache reuse, and isolation |

## References

- [JUnit 6 User Guide](https://docs.junit.org/current/user-guide/)
- [Testing plugins](https://docs.gradle.org/current/userguide/testing_gradle_plugins.html)
- [Gradle TestKit](https://docs.gradle.org/current/userguide/test_kit.html)
- [Testing best practices](https://docs.gradle.org/current/userguide/best_practices_testing.html)
- [Build Cache](https://docs.gradle.org/current/userguide/build_cache.html)
- [ProjectBuilder API](https://docs.gradle.org/current/javadoc/org/gradle/testfixtures/ProjectBuilder.html)
