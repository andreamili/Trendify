buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Firebase Gradle plugin za google-services.json
        classpath("com.google.gms:google-services:4.3.15")
        // Dodaj ovde druge buildscript zavisnosti ako postoje
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory
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
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}