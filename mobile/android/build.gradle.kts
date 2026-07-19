allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    // Some plugins (e.g. flutter_timezone) ship a Kotlin JVM target that
    // doesn't match their own Java compile target, which fails the build
    // under Gradle's strict consistency check. Bump Kotlin to 17 for every
    // subproject; the matching Java-side fix is below since it needs to run
    // after evaluation.
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

// Using afterEvaluate inside the subprojects block above conflicts with
// evaluationDependsOn(":app"); projectsEvaluated runs once everything is
// already evaluated, so it's safe to adjust task properties here instead.
gradle.projectsEvaluated {
    project(":flutter_timezone").tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
    // Same fix as flutter_timezone above — home_widget's own build.gradle
    // hardcodes Java 1.8, which now mismatches the Kotlin 17 bump forced on
    // every subproject above.
    project(":home_widget").tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
    // Same again — file_picker (10.x) hardcodes Java 11.
    project(":file_picker").tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
