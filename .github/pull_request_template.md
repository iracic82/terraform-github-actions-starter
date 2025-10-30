# Pull Request

## Description
<!-- Provide a brief description of the changes -->

## Type of Change
<!-- Mark the relevant option with an "x" -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement
- [ ] Test addition/update

## Related Issue
<!-- Link to the issue this PR addresses -->
Fixes #(issue number)

## Changes Made
<!-- List the changes made in this PR -->

-
-
-

## Affected Areas
<!-- Mark all that apply -->

- [ ] AWS infrastructure
- [ ] Azure infrastructure
- [ ] GitHub Actions workflows
- [ ] Terraform modules
- [ ] Documentation
- [ ] Scripts
- [ ] Configuration files

## Testing
<!-- Describe the tests you ran to verify your changes -->

### Testing Steps
1.
2.
3.

### Test Results
```
# Include relevant test output or screenshots
```

## Terraform Plan Output
<!-- If applicable, include terraform plan output -->

<details>
<summary>Terraform Plan</summary>

```hcl
# Paste terraform plan output here
```

</details>

## Checklist
<!-- Ensure all items are completed before submitting -->

### Code Quality
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have run `terraform fmt` on all Terraform files
- [ ] I have run `terraform validate` successfully

### Testing
- [ ] I have tested these changes locally
- [ ] I have run `terraform plan` successfully
- [ ] I have verified the changes don't break existing functionality
- [ ] I have added tests that prove my fix is effective or that my feature works

### Documentation
- [ ] I have updated the documentation accordingly
- [ ] I have updated the CHANGELOG.md
- [ ] I have updated module README files if applicable
- [ ] My changes generate no new warnings

### Security
- [ ] I have checked for hardcoded credentials (none added)
- [ ] I have followed security best practices
- [ ] I have not exposed sensitive information in logs or outputs

## Screenshots
<!-- If applicable, add screenshots to help explain your changes -->

## Breaking Changes
<!-- If this PR includes breaking changes, describe them here -->

None

<!-- OR -->

- **Breaking Change 1**: Description
- **Breaking Change 2**: Description

## Migration Guide
<!-- If breaking changes exist, provide migration steps -->

Not applicable

<!-- OR -->

1. Step 1
2. Step 2

## Additional Notes
<!-- Add any additional notes, context, or concerns -->

## Reviewer Notes
<!-- Specific areas you'd like reviewers to focus on -->

Please pay special attention to:
-
-

## Post-Merge Actions
<!-- List any actions that need to be taken after merging -->

- [ ] Update production environment
- [ ] Notify team in Slack/Teams
- [ ] Update related documentation
- [ ] Other: ___________

---

**By submitting this pull request, I confirm that my contribution is made under the terms of the MIT license.**
