# GitHub Actions Workflows

This repository contains several GitHub Actions workflows to automate the development and release process for the API Utility Flutter application.

## Workflows

### 1. CI (Continuous Integration) - `.github/workflows/ci.yml`

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**What it does:**
- Runs tests and code analysis
- Builds the app for Windows only
- Uploads test coverage to Codecov
- Verifies code formatting

### 2. Release - `.github/workflows/release.yml`

**Triggers:**
- Push of version tags (e.g., `v1.0.0`)
- Manual workflow dispatch

**What it does:**
- Builds the Windows release version
- Creates a release archive
- Publishes a GitHub release with the built application
- Uploads the release artifact

### 3. Version Bump - `.github/workflows/version-bump.yml`

**Triggers:**
- Manual workflow dispatch only

**What it does:**
- Automatically increments version in `pubspec.yaml`
- Updates the build number
- Generates changelog entries
- Optionally creates and pushes a new version tag

## How to Use

### Creating a New Release

#### Option 1: Using Version Bump Workflow (Recommended)

1. Go to the **Actions** tab in your GitHub repository
2. Select **Version Bump** workflow
3. Click **Run workflow**
4. Choose the version type:
   - **patch**: Bug fixes (1.0.0 → 1.0.1)
   - **minor**: New features (1.0.0 → 1.1.0)
   - **major**: Breaking changes (1.0.0 → 2.0.0)
5. Choose whether to create and push a tag
6. Click **Run workflow**

This will automatically:
- Update the version in `pubspec.yaml`
- Generate a changelog entry
- Create a new tag (if selected)
- Trigger the release workflow

#### Option 2: Manual Tag Creation

1. Update the version in `pubspec.yaml` manually
2. Commit and push the changes
3. Create a new tag: `git tag v1.0.0`
4. Push the tag: `git push origin v1.0.0`

This will automatically trigger the release workflow.

### Manual Release

1. Go to the **Actions** tab
2. Select **Release** workflow
3. Click **Run workflow**
4. Enter the version (e.g., `v1.0.0`)
5. Click **Run workflow**

## Workflow Dependencies

- **CI** runs on every push/PR to ensure code quality
- **Version Bump** can trigger **Release** if tag creation is enabled
- **Release** is triggered by version tags

## Requirements

### For Windows Builds
- Visual Studio 2022 with C++ tools
- MSBuild
- Flutter SDK


## Output Files

### Release Artifacts
- `api-utility-flutter-{version}-windows.zip` - Windows executable and dependencies

### Generated Files
- `CHANGELOG.md` - Automatically generated changelog
- Updated `pubspec.yaml` with new version

## Troubleshooting

### Common Issues

1. **Build fails on Windows**: Ensure Visual Studio components are properly installed
2. **Version bump fails**: Check that the current version format in `pubspec.yaml` is correct
3. **Release creation fails**: Verify that `GITHUB_TOKEN` has sufficient permissions

### Permissions Required

The workflows require the following permissions:
- `contents: write` - To push changes and create releases
- `pull-requests: write` - To comment on PRs (if needed)
- `issues: write` - To create issues (if needed)

## Customization

### Adding More Platforms

To add support for other platforms (Android, iOS, Web, Linux, macOS), modify the release workflow:

```yaml
- name: Build Android app
  run: flutter build apk --release
  
- name: Build iOS app
  run: flutter build ios --release --no-codesign
  
- name: Build Web app
  run: flutter build web --release
  
- name: Build Linux app
  run: flutter build linux --release
  
- name: Build macOS app
  run: flutter build macos --release
```

### Custom Release Notes

Modify the release body in `.github/workflows/release.yml` to include custom release notes, feature lists, or installation instructions.

### Environment Variables

You can add environment variables to the workflows for:
- API keys
- Build configurations
- Custom paths

## Security

- Never commit sensitive information like API keys or passwords
- Use GitHub Secrets for sensitive data
- Regularly review and update dependencies
- Use the latest versions of GitHub Actions
