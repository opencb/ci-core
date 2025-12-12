# Migration Instructions for Composite GitHub Actions

This document provides instructions for completing the migration of composite GitHub Actions from `opencb/java-common-libs` to `opencb/ci-core`.

## What Has Been Done

### 1. Actions Migrated to ci-core Repository

The following composite actions have been successfully copied from the `TASK-8067` branch of `opencb/java-common-libs` to this repository:

- `.github/actions/setup-java-maven/action.yml` - Sets up Java, dependencies, and Maven cache
- `.github/actions/test-summary/action.yml` - Generates and publishes test summaries

These actions are now available in the `opencb/ci-core` repository and can be referenced by other repositories.

### 2. Patch File Created for java-common-libs

A patch file (`java-common-libs-updates.patch`) has been created that contains all the necessary changes to update the workflow files in the `opencb/java-common-libs` repository (branch `TASK-8067`) to reference the migrated actions in `opencb/ci-core`.

## What Needs to Be Done

### Apply the Patch to opencb/java-common-libs

The patch file needs to be applied to the `TASK-8067` branch of the `opencb/java-common-libs` repository. This can be done using one of the following methods:

#### Method 1: Using git apply (Recommended)

```bash
# Clone the repository and checkout the TASK-8067 branch
git clone https://github.com/opencb/java-common-libs.git
cd java-common-libs
git checkout TASK-8067

# Apply the patch
git apply /path/to/java-common-libs-updates.patch

# Review the changes
git diff

# Commit and push the changes
git add .
git commit -m "Update action references to use opencb/ci-core repository"
git push origin TASK-8067
```

#### Method 2: Manual Updates

Alternatively, the following workflow files can be manually updated in the `TASK-8067` branch:

1. `.github/workflows/build-java-app-workflow.yml` - Line 43
   - Change: `uses: ./.github/actions/setup-java-maven`
   - To: `uses: opencb/ci-core/.github/actions/setup-java-maven@main`

2. `.github/workflows/test-analysis.yml` - Lines 24 and 39
   - Change: `uses: ./.github/actions/setup-java-maven`
   - To: `uses: opencb/ci-core/.github/actions/setup-java-maven@main`
   - Change: `uses: ./.github/actions/test-summary`
   - To: `uses: opencb/ci-core/.github/actions/test-summary@main`

3. `.github/workflows/test-xetabase-workflow.yml` - Line 126
   - Change: `uses: ./.github/actions/test-summary`
   - To: `uses: opencb/ci-core/.github/actions/test-summary@main`

## Summary of Changes

The patch updates 3 workflow files to use the centralized actions:

- **build-java-app-workflow.yml**: 1 reference updated
- **test-analysis.yml**: 2 references updated  
- **test-xetabase-workflow.yml**: 1 reference updated

Total: 4 action references now point to `opencb/ci-core/.github/actions/*@main`

## Verification

After applying the patch to the `opencb/java-common-libs` repository:

1. Verify that all workflow files reference the correct actions
2. Test the workflows to ensure they work correctly with the centralized actions
3. Monitor the first few workflow runs to catch any issues early

## Notes

- The actions use `@main` to reference the main branch of the ci-core repository
- If you need to reference a specific version or tag, update the `@main` suffix accordingly
- The actions in ci-core preserve all the original functionality and comments from java-common-libs
