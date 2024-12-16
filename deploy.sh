#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
BUILD_DIR="build/web"
DEPLOY_BRANCH="gh-pages"
COMMIT_MESSAGE="Deploying Flutter web build to GitHub Pages"

# Ensure the current branch is clean
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Please commit or stash your changes before running this script."
  exit 1
fi

# Build the Flutter web project
echo "Building Flutter web app..."
flutter build web --release

# Check if the deploy branch exists locally
if git show-ref --quiet refs/heads/$DEPLOY_BRANCH; then
  echo "Deploy branch exists locally."
else
  echo "Deploy branch does not exist. Creating it..."
  git branch $DEPLOY_BRANCH
fi

# Switch to the deploy branch
git checkout $DEPLOY_BRANCH

# Clean old content
echo "Cleaning old deployment files..."
rm -rf *

# Copy new build files
echo "Copying new build files..."
cp -r $BUILD_DIR/* .

# Add, commit, and push changes
echo "Deploying to GitHub Pages..."
git add .
git commit -m "$COMMIT_MESSAGE"
git push origin $DEPLOY_BRANCH --force

# Switch back to the main branch
git checkout -

echo "Deployment complete!"
