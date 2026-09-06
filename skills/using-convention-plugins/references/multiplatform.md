# Multiplatform Projects

## [KMP] Targets and source sets

- Configure module conventions with `kotlinMultiplatformApplication` or `kotlinMultiplatformLibrary`; declare required targets in `kotlin { ... }`.
- Use the default hierarchy already applied by the convention; put shared code and dependencies in the narrowest applicable shared source set.
- Use KSP's target-specific configurations when adding processors; KSP is already applied.
- Use the shared [feature switches](build-features.md) for serialization, redaction, BuildConfig, and ABI validation.
- Follow the [KMP test rules](testing-and-quality.md#kmp-tests-on-all-targets) when adding test source sets.

## [KMP] Optional features

| When | Enable | Then use |
|---|---|---|
| Configure the [benchmarking library](tech-stack.md#benchmarking) | `buildFeatures.benchmark = true` | Shared `src/benchmark/kotlin` code and generated per-target benchmark compilations; runtime dependencies and benchmark targets are provided |
| Configure the [dependency injection library](tech-stack.md#dependency-injection) | `buildFeatures.metro = true` | The convention applies the compiler plugin; configure its DSL and annotations as needed |
| Generate Kotlin/Native bindings for C headers | `buildFeatures.cinterop = true` | The main-compilation interop named after the project, `src/nativeInterop/cinterop/<project-name>.def`, and headers under that directory |

- Optional KMP features default to disabled.
- Keep C interop disabled unless the module needs C bindings.
- If C interop is needed, enable it before declaring Native targets; the convention reads that flag while configuring each target.
- When C interop is enabled, set the module's `packageName` to the generated bindings package; configure additional interops explicitly when more than the supplied main interop is needed.

## [KMP] Native and Wasm application behavior

- For iOS, tvOS, and watchOS targets, reuse the generated static framework named after the project.
- For other Native application targets, put `main` in the configured package; the convention supplies the executable entry point.
- For Wasm/JS application targets, reuse the executable binary enabled by the convention.
- Use the generated host-native `runDebugExecutable` / `runReleaseExecutable` aliases when running a Native application locally.

## References

- [KMP application plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/KotlinMultiplatformApplicationConventionPlugin.kt)
- [KMP library plugin](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/KotlinMultiplatformLibraryConventionPlugin.kt)
- [KMP library extension name](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/api/kotlin/io/technoirlab/conventions/kotlin/multiplatform/api/KotlinMultiplatformLibraryExtension.kt)
- [KMP targets, hierarchy, BOMs, ABI, and C interop](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/configuration/KotlinMultiplatform.kt)
- [KMP feature defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/internal/KotlinMultiplatformBuildFeaturesImpl.kt)
- [KMP benchmark configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/configuration/Benchmarking.kt)
- [Metro feature wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/configuration/Metro.kt)
