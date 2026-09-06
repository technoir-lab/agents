# Implementing Tasks

## Contents

- [Task type contract](#task-type-contract)
- [CLI options](#cli-options)
- [Service injection](#service-injection)
- [Worker API](#worker-api)
- [Incremental tasks](#incremental-tasks)
- [Path sensitivity](#path-sensitivity)
- [Failures and problems](#failures-and-problems)
- [Dataflow actions](#dataflow-actions)
- [Common mistakes](#common-mistakes)

## Task type contract

- Use an abstract task type with managed, annotated properties; choose visibility according to the [support boundary](plugin-api-design.md#support-boundary).
- Mark cacheable work with `@CacheableTask`; otherwise explain the reason with `@DisableCachingByDefault`.
- Use `@UntrackedTask(because = "...")` only when Gradle cannot or should not snapshot task state. Untracked tasks always run, cannot use `InputChanges`, and never use the build cache.
- Give each task a unique output file or directory.
- Use lazy file collection APIs; avoid iterating inputs during configuration.
- Keep `Project`, `Configuration`, `SourceSet`, and other configuration models out of task actions.
- Put serializable values, files, services, and worker parameters into task state.
- Give user-invocable tasks a stable name, `group`, and `description`, independently of their Kotlin type visibility.
- Omit `group` and `description` from implementation-only tasks.

## CLI options

Expose a task-local option with `@Option`; keep the underlying property annotated as an input.

```kotlin
import org.gradle.api.tasks.options.Option

@get:Input
@get:Option(option = "format", description = "Select the report format")
abstract val format: Property<String>
```

Use `@OptionValues` only for finite suggestions. Do not model project-wide plugin configuration as task options.

## Service injection

- Use `@Inject constructor` on Gradle-created types.
- Keep services in private constructor properties.
- Keep task inputs and outputs in managed properties.
- Inject only supported public services.

| Availability | Injectable service | Use |
|---|---|---|
| All Gradle-created types | `ObjectFactory` | Managed objects, properties, collections, files |
| All Gradle-created types | `ProviderFactory` | Lazy values; Gradle, environment, and system properties |
| All Gradle-created types | `FileSystemOperations` | Copy, sync, delete |
| All Gradle-created types | `ArchiveOperations` | Read and extract archives |
| All Gradle-created types | `ExecOperations` | External and Java processes |
| All Gradle-created types | `Problems` | Structured diagnostics |
| Project and Settings types | `ToolingModelBuilderRegistry` | Tooling API models |
| Project and Settings types | `DependencyFactory` | Dependencies without `Project` access |
| Project and Settings types | `DependencyConstraintFactory` | Dependency constraints without `Project` access |
| Project and Settings types | `BuildFeatures` | Configuration Cache and Isolated Projects state |
| Project and Settings types | `FlowScope`, `FlowProviders` | Build-lifecycle dataflow actions |
| Project and Settings types | `BuildInvocationDetails` | Build start time |
| Project types | `ProjectLayout` | Project and build locations |
| Project types | `WorkerExecutor` | Parallel and isolated work |
| Project types | `TestEventReporterFactory` | Custom test-event reporting |
| Project types | `SoftwareComponentFactory` | Ad hoc publishable components |
| Settings types | `BuildLayout` | Root directory and settings file |

## Worker API

| Queue | Isolation | Choose when |
|---|---|---|
| `noIsolation()` | Shared process and classloader | Trusted, lightweight work using the plugin classpath |
| `classLoaderIsolation()` | Separate classloader | Conflicting libraries or a dedicated worker classpath |
| `processIsolation()` | Separate worker process | Process state, JVM arguments, memory, or native isolation matters |

- Submit immutable managed parameters.
- Keep `WorkAction` stateless apart from parameters.
- Pass a build service to workers only with `noIsolation()`.
- Avoid `await()` unless the task must consume worker results before its action returns.
- Map each input to a unique output; the example requires unique input file names.

```kotlin
import org.gradle.kotlin.dsl.submit
import org.gradle.workers.WorkAction
import org.gradle.workers.WorkParameters
import org.gradle.workers.WorkerExecutor
import javax.inject.Inject

internal abstract class ExampleAction : WorkAction<ExampleAction.Parameters> {
    override fun execute() {
        val inputFile = parameters.inputFile.get().asFile
        val outputFile = parameters.outputFile.get().asFile
        outputFile.parentFile.mkdirs()
        outputFile.writeText(inputFile.readText().uppercase())
    }

    interface Parameters : WorkParameters {
        val inputFile: RegularFileProperty
        val outputFile: RegularFileProperty
    }
}

@CacheableTask
internal abstract class ExampleTask @Inject constructor(
    private val workerExecutor: WorkerExecutor,
) : DefaultTask() {
    @get:InputFiles
    @get:PathSensitive(PathSensitivity.NAME_ONLY)
    abstract val inputFiles: ConfigurableFileCollection

    @get:OutputDirectory
    abstract val outputDirectory: DirectoryProperty

    @TaskAction
    fun render() {
        val queue = workerExecutor.noIsolation()
        inputFiles.files.sortedBy { it.name }.forEach { inputFile ->
            queue.submit(ExampleAction::class) {
                this.inputFile.set(inputFile)
                outputFile.set(outputDirectory.file("${inputFile.name}.rendered"))
            }
        }
    }
}
```

## Incremental tasks

- Add `@Incremental` or `@SkipWhenEmpty` to at least one file input.
- Use one `@TaskAction` with one `InputChanges` parameter.
- Query each incremental property with `getFileChanges()`.
- Handle `ADDED`, `MODIFIED`, and `REMOVED` files.
- During non-incremental execution, process all files reported as `ADDED`; Gradle removes previous outputs.

```kotlin
import org.gradle.api.file.FileType
import org.gradle.work.ChangeType
import org.gradle.work.Incremental
import org.gradle.work.InputChanges

@CacheableTask
internal abstract class ExampleTask : DefaultTask() {
    @get:Incremental
    @get:InputDirectory
    @get:PathSensitive(PathSensitivity.RELATIVE)
    abstract val inputDirectory: DirectoryProperty

    @get:OutputDirectory
    abstract val outputDirectory: DirectoryProperty

    @TaskAction
    fun normalize(inputChanges: InputChanges) {
        inputChanges.getFileChanges(inputDirectory).forEach { change ->
            if (change.fileType == FileType.DIRECTORY) return@forEach

            val outputFile = outputDirectory.file(change.normalizedPath).get().asFile
            if (change.changeType == ChangeType.REMOVED) {
                outputFile.delete()
            } else {
                outputFile.parentFile.mkdirs()
                outputFile.writeText(change.file.readText().trimEnd() + "\n")
            }
        }
    }
}
```

## Path sensitivity

| Input semantics | Sensitivity |
|---|---|
| Only file contents matter | `NONE` |
| File name matters; location does not | `NAME_ONLY` |
| Relative path or directory layout matters | `RELATIVE` |
| Absolute location affects behavior | `ABSOLUTE` only when unavoidable |

## Failures and problems

| Need | Mechanism |
|---|---|
| Invalid plugin configuration | Throw a focused `GradleException` or structured Problems API failure |
| Recoverable diagnostic | `problems.reporter.report(PROBLEM_ID) { ... }` |
| Fatal structured diagnostic | `throw problems.reporter.throwing(exception, PROBLEM_ID) { ... }` |
| Verification failed but valid outputs exist | `VerificationException` |

- Define stable `ProblemGroup` and `ProblemId` values.
- Inject `Problems`; obtain its `reporter` before calling `report` or `throwing`.
- Supply contextual labels, details, locations, and solutions without secrets.
- Let `report()` versus `throwing()` express severity; do not call deprecated severity setters.
- Throw `VerificationException` only from verification work whose outputs remain valid.

```kotlin
import org.gradle.api.problems.ProblemGroup
import org.gradle.api.problems.ProblemId
import org.gradle.api.problems.Problems
import org.gradle.work.DisableCachingByDefault
import javax.inject.Inject

private object ExampleProblems {
    val group = ProblemGroup.create("com.example.reports", "Report rendering")
    val legacyFormat = ProblemId.create("legacy-format", "Legacy report format", group)
}

@DisableCachingByDefault(because = "Reports diagnostics only")
internal abstract class ExampleTask : DefaultTask() {
    @get:Input
    abstract val format: Property<String>

    @get:Inject
    abstract val problems: Problems

    @TaskAction
    fun validate() {
        if (format.get() == "legacy") {
            problems.reporter.report(ExampleProblems.legacyFormat) {
                contextualLabel("Report format 'legacy' is deprecated")
                details("The legacy renderer is scheduled for removal.")
                solution("Set the report format to 'html'.")
            }
        }
    }
}
```

## Dataflow actions

Use `FlowAction` for isolated lifecycle work that does not belong to a task, such as reacting to build completion.

- Inject `FlowScope` and register with `always`.
- Model inputs through a `FlowParameters` type.
- Wire `FlowProviders.buildWorkResult` when execution must wait for build work.
- Keep ordinary build outputs in tasks, not flow actions.

```kotlin
import org.gradle.api.flow.FlowAction
import org.gradle.api.flow.FlowParameters
import org.gradle.api.flow.FlowProviders
import org.gradle.api.flow.FlowScope
import org.gradle.api.logging.Logging
import org.gradle.kotlin.dsl.always
import javax.inject.Inject

internal abstract class ExampleAction : FlowAction<ExampleAction.Parameters> {
    private val logger = Logging.getLogger(ExampleAction::class.java)

    override fun execute(parameters: Parameters) {
        val status = if (parameters.buildFailed.get()) "failed" else "succeeded"
        logger.lifecycle("Build {}", status)
    }

    interface Parameters : FlowParameters {
        @get:Input
        val buildFailed: Property<Boolean>
    }
}

internal class ExamplePlugin @Inject constructor(
    private val flowScope: FlowScope,
    private val flowProviders: FlowProviders,
) : Plugin<Project> {
    override fun apply(project: Project) {
        flowScope.always(ExampleAction::class) {
            parameters.buildFailed.set(
                flowProviders.buildWorkResult.map { it.failure.isPresent },
            )
        }
    }
}
```

## Common mistakes

| Mistake | Correction |
|---|---|
| Task action reads `project` | Declare the required value as an input during configuration |
| Manual thread or executor creation | Submit work through `WorkerExecutor` |
| `VerificationException` for configuration errors | Use a normal or structured fatal failure |
| User task without discoverability metadata | Add stable `group` and `description` |

## References

- [DisableCachingByDefault annotation](https://docs.gradle.org/current/javadoc/org/gradle/work/DisableCachingByDefault.html)
- [Gradle Kotlin DSL: Work submission extension](https://docs.gradle.org/current/kotlin-dsl/gradle/org.gradle.kotlin.dsl/submit.html)
- [Implementing custom tasks](https://docs.gradle.org/current/userguide/custom_tasks.html)
- [Incremental tasks](https://docs.gradle.org/current/userguide/custom_tasks.html#incremental_tasks)
- [Task best practices](https://docs.gradle.org/current/userguide/best_practices_tasks.html)
- [Service injection](https://docs.gradle.org/current/userguide/service_injection.html)
- [Worker API](https://docs.gradle.org/current/userguide/worker_api.html)
- [Reporting problems](https://docs.gradle.org/current/userguide/reporting_problems.html)
- [Dataflow actions](https://docs.gradle.org/current/userguide/dataflow_actions.html)
