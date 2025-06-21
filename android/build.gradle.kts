allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
buildscript {
    repositories {
        google()       // Add this
        mavenCentral() // Add this
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0") // your android gradle plugin version
        classpath("com.google.gms:google-services:4.3.15") // Google services plugin
          // ✅ Ajoute cette ligne pour le core library desugaring
      

    }
}

allprojects {
    repositories {
        google()       // Add this too
        mavenCentral() // Add this too
    }
}
