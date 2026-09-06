# Publishing and Documentation

- For JVM libraries, KMP libraries, and Gradle plugin modules, reuse the supplied Maven publications: `libraryMaven`, `kotlinMultiplatform`, or `pluginMaven`, respectively.

## Maven Central publication

- Optional: configure Maven Central publication only when requested or required by the repository's existing publication workflow.

### Project metadata

- Set `project.groupId` in the root `gradle.properties` to a group ID within a namespace verified for the publishing account, such as `io.technoirlab.<domain>`.
- Configure `description`, project `url`, maintainer `developer(...)` entries, and `license(name, url)` entries in `globalSettings.metadata`.
- Set `description` in a module's convention metadata, such as `gradlePluginConfig.metadata.description`, only when the global description cannot describe every module.
- Reuse accurate convention defaults; supply missing information from the repository's actual project details.
- Let conventions map metadata into Maven POMs and Gradle plugin display names/descriptions; configure it once through the metadata DSL.
- Reuse the convention's repository-derived SCM information; verify it identifies the published source repository.
- Review generated POMs for complete and accurate metadata before publication.

### Publication setup

- Add `nmcpAggregation(project(":module"))` dependencies at the root for modules being published to Maven Central.
- Provide `SIGNING_KEY` and `SIGNING_PASSWORD` through the environment for publication signing; the convention configures in-memory keys.
- Use the settings convention's NMCP setup and `CENTRAL_PORTAL_USER` / `CENTRAL_PORTAL_PASSWORD`; publishing mode is `USER_MANAGED`.
- Inspect the existing publication and repository tasks before running the project's release procedure.
- When targeting a custom remote repository, configure `publish.<name>.url`; supply both `publish.<name>.username` and `publish.<name>.password` when authentication is required.

## Maven Local publication

- Publish modules for local consumption with `./gradlew :module:publishToMavenLocal`.
- Reuse the Gradle plugin convention's automatic local publication before functional tests; Maven Central setup is not required for those tests.
- Use the project's [coordinates and default version](project-setup.md#settings-and-coordinates).

### Concurrent publication

- Isolate versions only when concurrent builds can publish different artifacts to the same Maven Local coordinates; otherwise, retain the project's default version, including `dev` for local functional tests.
- When isolation is needed, choose a unique version per producer work session and pass it with `-Pproject.version=<agent-version>` to every build that publishes to Maven Local, including functional tests that publish automatically.
- Use the same version when publishing and consuming those artifacts; pass the same `-Pproject.version=<agent-version>` to related test/consumer builds and ensure their dependency or plugin declarations resolve that exact producer version.
- In a separate consumer project, `project.version` sets the consumer's own version; it does not automatically change dependency or plugin versions. Set the consumed library version or `conventionPluginsVersion` explicitly to the producer's chosen version as applicable.

## Documentation

- Reuse the supplied sources and documentation artifacts; documentation generation is attached to `build`.
- Keep implementation packages under `internal` when they should be hidden from generated API documentation.
- When aggregate documentation is requested or required by an existing repository workflow, add `dokka(project(":module"))` dependencies at the root for the selected modules.
- Run `:dokkaGenerate` for aggregate documentation; applying the root convention alone does not select child projects for aggregation.

## References

- [Maven Central: Required POM metadata](https://central.sonatype.org/publish/requirements/#required-pom-metadata)
- [Maven Central: Namespace registration and verification](https://central.sonatype.org/register/namespace/)
- [Project metadata DSL](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/api/kotlin/io/technoirlab/conventions/common/api/metadata/ProjectMetadata.kt)
- [Shared metadata defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/settings-conventions/src/main/kotlin/io/technoirlab/conventions/settings/SettingsConventionPlugin.kt)
- [Gradle plugin metadata mapping](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/configuration/Plugin.kt)
- [Maven publishing and signing configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Publishing.kt)
- [Dokka configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Dokka.kt)
- [JVM library plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/jvm-conventions/src/main/kotlin/io/technoirlab/conventions/jvm/JvmLibraryConventionPlugin.kt)
- [KMP library plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/KotlinMultiplatformLibraryConventionPlugin.kt)
- [Gradle plugin convention implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginConventionPlugin.kt)
- [Publishing repository properties and environment](https://github.com/technoir-lab/convention-plugins/blob/main/libraries/gradle-extensions/src/main/kotlin/io/technoirlab/gradle/Environment.kt)
- [Maven Central publishing configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/settings-conventions/src/main/kotlin/io/technoirlab/conventions/settings/configuration/Publishing.kt)
- [Root plugin implementation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/root-conventions/src/main/kotlin/io/technoirlab/conventions/root/RootConventionPlugin.kt)
- [Root aggregation examples](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/root-conventions/src/functionalTest/kotlin/io/technoirlab/conventions/root/RootConventionPluginTest.kt)
