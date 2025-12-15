# ci-core

Core CI/CD components for OpenCB and Xetabase projects. Centralized reusable GitHub Actions, composite actions, and internal workflows implementing our organization's opinionated build, test, and release rules.

## Available Composite Actions

### setup-java-maven

**Location:** `.github/actions/setup-java-maven/`

Sets up Java, dependencies, and Maven cache for OpenCB projects.

**Usage:**
```yaml
- name: Setup Java and Maven
  uses: opencb/ci-core/.github/actions/setup-java-maven@main
  with:
    java_version: '11'                    # Optional, default: '11'
    storage_hadoop: 'hdi5.1'              # Optional, default: 'hdi5.1'
    dependency_repos: 'repo1,repo2'       # Optional, default: ''
    require_cache_hit: 'false'            # Optional, default: 'false'
```

**Inputs:**
- `java_version`: Java version to use (default: "11")
- `storage_hadoop`: Hadoop flavour, used as part of the Maven cache key (default: "hdi5.1")
- `dependency_repos`: Comma-separated list of dependency repositories to clone and compile
- `require_cache_hit`: If true, fail the job when the Maven cache is not found

**Outputs:**
- `dependencies_sha`: Hash representing dependency commits
- `cache-hit`: True if the Maven cache was found

### test-summary

**Location:** `.github/actions/test-summary/`

Generates a Markdown summary of Surefire test results and writes it to GITHUB_STEP_SUMMARY.

**Usage:**
```yaml
- name: Generate Test Summary
  uses: opencb/ci-core/.github/actions/test-summary@main
  with:
    report_paths: './**/surefire-reports/TEST-*.xml'  # Optional
    title: 'Test Results'                              # Optional
    include_module_table: 'true'                       # Optional
```

**Inputs:**
- `report_paths`: Glob pattern for Surefire XML reports (default: "./**/surefire-reports/TEST-*.xml")
- `title`: Title for the test summary section (default: "Test summary")
- `include_module_table`: Whether to include the per-module breakdown table (default: "true")

**Outputs:**
- `total_success`: Total number of successful tests
- `total_failed`: Total number of failed tests
- `total_errors`: Total number of tests with errors
- `total_skipped`: Total number of skipped tests
- `total_tests`: Total number of tests

