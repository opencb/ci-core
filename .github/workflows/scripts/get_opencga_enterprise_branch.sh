#!/usr/bin/env bash
# get_opencga_enterprise_branch.sh
#
# This script computes the correct opencga-enterprise branch to use for testing a PR in any Xetabase component repo.
# It unifies the logic previously duplicated in java-common-libs, biodata, and opencga.
#
# Inputs:
#   1. project (artifactId from pom.xml)
#   2. base_ref (target branch of the PR)
#   3. head_ref (source branch of the PR)
#
# Output:
#   Prints the resolved opencga-enterprise branch to stdout.
#   Exits with non-zero and error message if it cannot resolve a branch.

set -euo pipefail

project="$1"
base_ref="$2"
head_ref="$3"
# Check that ZETTA_REPO_ACCESS_TOKEN is set
if [ -z "$ZETTA_REPO_ACCESS_TOKEN" ]; then
  echo "ZETTA_REPO_ACCESS_TOKEN should be set to access private repositories" >&2
  exit 1
else
  echo "ZETTA_REPO_ACCESS_TOKEN is ok (defined)" >&2
fi

# Configura estos valores:
REPO="zetta-genomics/opencga-enterprise"
BRANCH="TASK-8067"  # O cualquier rama que exista
TOKEN="${ZETTA_REPO_ACCESS_TOKEN}"

if [ -z "$TOKEN" ]; then
  echo "ERROR: ZETTA_REPO_ACCESS_TOKEN está vacío"
  exit 1
fi

echo "Probando acceso a https://github.com/$REPO con el token..."

# Prueba acceso a la rama
git ls-remote --heads "https://$TOKEN@github.com/$REPO.git" "$BRANCH"
RESULT=$?

if [ $RESULT -eq 0 ]; then
  echo "ÉXITO: El token tiene acceso de lectura al repositorio y puede ver la rama '$BRANCH'."
else
  echo "FALLO: El token NO tiene acceso al repositorio o la rama no existe."
  echo "Verifica que el token tenga permisos de lectura y acceso al repo."
fi






# Helper: check if a branch exists in the remote opencga-enterprise repo
branch_exists() {
  local branch="$1"
  REPO_URI="https://$ZETTA_REPO_ACCESS_TOKEN@github.com/zetta-genomics/opencga-enterprise.git"
  echo "DEBUG: Probing $REPO_URI for branch $branch" >&2
  git ls-remote --heads "$REPO_URI" "$branch" >&2
  git ls-remote --heads "$REPO_URI" "$branch" | grep -q refs/heads
}

# 1. TASK-* branch logic: if head_ref starts with TASK- and exists in opencga-enterprise, use it
if [[ "$head_ref" =~ ^TASK- ]]; then
  if branch_exists "$head_ref"; then
    echo "$head_ref"
    exit 0
  fi
fi

# 2. develop branch logic: always map to develop
if [[ "$base_ref" == "develop" ]]; then
  echo "develop"
  exit 0
fi

# 3. release-* branch logic
if [[ "$base_ref" =~ ^release-([0-9]+)\. ]]; then
  major="${BASH_REMATCH[1]}"
  # Project-specific offset for release branch mapping
  case "$project" in
    java-common-libs)
      offset=3
      ;;
    biodata|opencga)
      offset=1
      ;;
    opencga-enterprise)
      # If the project is opencga-enterprise, use the branch as-is
      echo "$base_ref"
      exit 0
      ;;
    *)
      echo "ERROR: Unknown project '$project' for release branch mapping" >&2
      exit 1
      ;;
  esac
  new_major=$((major - offset))
  if (( new_major < 1 )); then
    echo "ERROR: Computed release branch version < 1 for $project (base_ref: $base_ref, offset: $offset)" >&2
    exit 1
  fi
  # Try to match release-x.x.x, fallback to release-x.x
  branch_pattern="release-${new_major}."
  # Find the latest matching branch in opencga-enterprise (usando el token)
  branch=$(git ls-remote --heads "https://$ZETTA_REPO_ACCESS_TOKEN@github.com/zetta-genomics/opencga-enterprise.git" | grep "refs/heads/${branch_pattern}" | awk -F'refs/heads/' '{print $2}' | sort -Vr | head -n1)
  if [[ -n "$branch" ]]; then
    echo "$branch"
    exit 0
  else
    echo "ERROR: No matching release branch found in opencga-enterprise for $project (pattern: $branch_pattern)" >&2
    exit 1
  fi
fi

# 4. Fallback: fail with clear error
echo "ERROR: Could not resolve opencga-enterprise branch for project '$project' (base_ref: $base_ref, head_ref: $head_ref)" >&2
exit 1
