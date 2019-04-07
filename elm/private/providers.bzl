ElmLibrary = provider()

def create_elm_library_provider(deps, dependencies, package_directories, source_directories, source_files):
    return ElmLibrary(
        dependencies = depset(
            dependencies,
            transitive = [
                dep[ElmLibrary].dependencies
                for dep in deps
            ],
        ),
        package_directories = depset(
            package_directories,
            transitive = [
                dep[ElmLibrary].package_directories
                for dep in deps
            ],
        ),
        source_directories = depset(
            source_directories,
            transitive = [
                dep[ElmLibrary].source_directories
                for dep in deps
            ],
        ),
        source_files = depset(
            source_files,
            transitive = [
                dep[ElmLibrary].source_files
                for dep in deps
            ],
        ),
    )
