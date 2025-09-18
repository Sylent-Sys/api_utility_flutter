# GitHub Workflows Documentation

## Overview
Dokumentasi untuk GitHub Actions workflows yang digunakan dalam proyek API Utility Flutter.

## 🔄 Version Bump Workflow

### File: `.github/workflows/version-bump.yml`

Workflow ini digunakan untuk melakukan version bump otomatis dengan update changelog yang cerdas.

### Features

#### 🎯 **Smart Changelog Management**
- **Duplicate Prevention**: Tidak akan menambahkan changelog untuk versi yang sudah ada
- **Version Detection**: Otomatis mendeteksi apakah versi sudah ada di changelog
- **Selective Update**: Bisa memilih apakah changelog diupdate atau tidak

#### 📝 **Version Bump Options**
- **Patch**: Increment patch version (1.0.0 → 1.0.1)
- **Minor**: Increment minor version (1.0.0 → 1.1.0)
- **Major**: Increment major version (1.0.0 → 2.0.0)

#### 🏷️ **Tag Management**
- **Optional Tag Creation**: Bisa memilih apakah tag dibuat atau tidak
- **Automatic Tagging**: Tag dibuat dengan format `v{major}.{minor}.{patch}`

### Input Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `version_type` | choice | `patch` | Type of version bump (patch/minor/major) |
| `create_tag` | boolean | `true` | Whether to create and push git tag |
| `update_changelog` | boolean | `true` | Whether to update changelog (skip if version exists) |

### Usage

#### Manual Trigger
1. Go to **Actions** tab in GitHub repository
2. Select **Version Bump** workflow
3. Click **Run workflow**
4. Configure parameters:
   - **Version Type**: Choose patch/minor/major
   - **Create Tag**: Enable/disable tag creation
   - **Update Changelog**: Enable/disable changelog update
5. Click **Run workflow**

#### Example Scenarios

##### Scenario 1: Patch Version with Changelog
```
Version Type: patch
Create Tag: true
Update Changelog: true
```
**Result**: 
- Version: 2.0.0 → 2.0.1
- Tag: v2.0.1 created
- Changelog: Entry added (if not exists)

##### Scenario 2: Major Version without Changelog
```
Version Type: major
Create Tag: true
Update Changelog: false
```
**Result**:
- Version: 2.0.0 → 3.0.0
- Tag: v3.0.0 created
- Changelog: No changes

##### Scenario 3: Re-run for Existing Version
```
Version Type: patch
Create Tag: false
Update Changelog: true
```
**Result**:
- Version: 2.0.1 → 2.0.2
- Tag: No tag created
- Changelog: Entry added (if v2.0.2 not exists)

### Workflow Steps

#### 1. **Checkout Code**
```yaml
- name: Checkout code
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    fetch-depth: 0
```

#### 2. **Get Current Version**
```yaml
- name: Get current version
  id: current_version
  run: |
    CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
    echo "CURRENT_VERSION=$CURRENT_VERSION" >> $GITHUB_OUTPUT
```

#### 3. **Calculate New Version**
```yaml
- name: Calculate new version
  id: new_version
  run: |
    # Extract version parts
    VERSION_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f1)
    BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)
    
    # Increment based on type
    case $VERSION_TYPE in
      major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
      minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
      patch) PATCH=$((PATCH + 1)) ;;
    esac
    
    # Increment build number
    BUILD_NUMBER=$((BUILD_NUMBER + 1))
```

#### 4. **Update pubspec.yaml**
```yaml
- name: Update pubspec.yaml
  run: |
    NEW_VERSION="${{ steps.new_version.outputs.NEW_VERSION }}"
    sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
```

#### 5. **Generate Changelog Entry** (Conditional)
```yaml
- name: Generate changelog entry
  if: ${{ github.event.inputs.update_changelog == 'true' }}
  run: |
    # Check if version already exists
    if grep -q "## \[$NEW_TAG\]" CHANGELOG.md; then
      echo "Version already exists, skipping changelog update"
      exit 0
    fi
    
    # Create changelog entry
    cat > changelog_entry.tmp << EOF
    ## [$NEW_TAG] - $(date +%Y-%m-%d)
    
    ### $VERSION_TYPE version bump
    - Version bumped from $CURRENT_VERSION to $NEW_VERSION
    - Automated release build
    
    ### Changes
    - See commit history for detailed changes
    EOF
```

#### 6. **Commit Changes**
```yaml
- name: Commit changes
  run: |
    git add pubspec.yaml
    
    if [ "${{ github.event.inputs.update_changelog }}" = "true" ]; then
      if git diff --cached --quiet CHANGELOG.md; then
        git commit -m "chore: bump version to $NEW_VERSION"
      else
        git add CHANGELOG.md
        git commit -m "chore: bump version to $NEW_VERSION"
      fi
    else
      git commit -m "chore: bump version to $NEW_VERSION"
    fi
```

#### 7. **Create and Push Tag** (Conditional)
```yaml
- name: Create and push tag
  if: ${{ github.event.inputs.create_tag == 'true' }}
  run: |
    NEW_TAG="${{ steps.new_version.outputs.NEW_TAG }}"
    git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
    git push --follow-tags origin main
```

### Changelog Format

#### Generated Entry Format
```markdown
## [v2.0.1] - 2024-12-18

### patch version bump
- Version bumped from 2.0.0+5 to 2.0.1+6
- Automated release build

### Changes
- See commit history for detailed changes
```

#### Duplicate Prevention
- **Detection**: Uses `grep -q "## \[$NEW_TAG\]"` to check if version exists
- **Skip Logic**: Exits early if version already exists
- **No Duplicates**: Prevents multiple entries for same version

### Error Handling

#### Common Issues
1. **Version Already Exists**: Workflow skips changelog update
2. **File Not Found**: Creates new changelog if not exists
3. **Git Conflicts**: Uses `git pull --rebase` to handle conflicts
4. **Permission Issues**: Uses `GITHUB_TOKEN` for authentication

#### Troubleshooting
- **Check Logs**: Review workflow logs for detailed error messages
- **Verify Permissions**: Ensure `GITHUB_TOKEN` has write permissions
- **Check Branch**: Ensure workflow runs on correct branch
- **Validate Input**: Verify input parameters are correct

### Best Practices

#### Version Bump Strategy
1. **Patch**: Bug fixes, minor improvements
2. **Minor**: New features, backward compatible
3. **Major**: Breaking changes, major refactoring

#### Changelog Management
1. **Manual Entries**: Add detailed changelog entries manually
2. **Automated Bumps**: Use workflow for version bumps only
3. **Review Changes**: Always review generated changelog entries
4. **Consistent Format**: Maintain consistent changelog format

#### Tag Management
1. **Semantic Versioning**: Follow semantic versioning principles
2. **Tag Messages**: Use descriptive tag messages
3. **Release Notes**: Create release notes for major versions
4. **Tag Cleanup**: Remove unnecessary tags if needed

### Integration

#### With Release Process
1. **Version Bump**: Use workflow to bump version
2. **Manual Review**: Review changelog and code changes
3. **Create Release**: Use GitHub releases with generated tag
4. **Deploy**: Deploy using version tag

#### With CI/CD
1. **Trigger Build**: Version bump can trigger build process
2. **Automated Testing**: Run tests on new version
3. **Deployment**: Deploy to staging/production
4. **Notification**: Notify team of new version

### Security

#### Permissions
- **Contents Write**: Required for updating files and creating tags
- **GITHUB_TOKEN**: Used for authentication
- **Branch Protection**: Respects branch protection rules

#### Best Practices
- **Minimal Permissions**: Only grant necessary permissions
- **Token Security**: Use secure token management
- **Audit Logs**: Monitor workflow executions
- **Access Control**: Limit who can trigger workflows

## 🔮 Future Enhancements

### Planned Features
- **Automatic Release Notes**: Generate release notes from commits
- **Version Validation**: Validate version format and conflicts
- **Multi-branch Support**: Support for different branch strategies
- **Integration Tests**: Run tests before version bump

### UI Improvements
- **Workflow Dashboard**: Better workflow management interface
- **Parameter Validation**: Client-side parameter validation
- **Progress Indicators**: Real-time progress updates
- **Error Reporting**: Better error reporting and recovery

### Advanced Features
- **Custom Changelog Templates**: Configurable changelog formats
- **Version Comparison**: Compare versions and changes
- **Rollback Support**: Rollback to previous versions
- **Analytics**: Version bump analytics and insights
