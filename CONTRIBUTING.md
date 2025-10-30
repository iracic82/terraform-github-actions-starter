# Contributing to Terraform GitHub Actions Starter

First off, thank you for considering contributing to this project! It's people like you that make this template better for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code samples, screenshots, etc.)
- **Describe the behavior you observed** and **what you expected to see**
- **Include details about your environment** (OS, Terraform version, cloud provider, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List any alternative solutions** you've considered

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Write clear commit messages**
6. **Submit a pull request**

## Development Process

### Setting Up Development Environment

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/terraform-github-actions-starter.git
cd terraform-github-actions-starter

# Create a branch
git checkout -b feature/your-feature-name

# Make changes and test
cd environments/aws-dev
terraform init
terraform validate
terraform plan
```

### Coding Standards

#### Terraform Code

- **Use consistent formatting**: Run `terraform fmt` before committing
- **Add comments**: Explain complex logic
- **Use variables**: Don't hardcode values
- **Module documentation**: Update module README.md files
- **Naming conventions**:
  - Resources: `snake_case`
  - Variables: descriptive names
  - Modules: `kebab-case`

#### Documentation

- **Use clear headings** and structure
- **Provide examples** wherever possible
- **Keep it up to date** with code changes
- **Use proper markdown** formatting

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(aws): add support for EC2 instance profiles

docs(setup): update AWS backend configuration steps

fix(workflows): correct terraform plan output formatting
```

### Testing Guidelines

Before submitting a pull request:

1. **Test Terraform code**:
   ```bash
   terraform init
   terraform validate
   terraform plan
   ```

2. **Test workflows locally** (if possible):
   ```bash
   act -l  # Using nektos/act
   ```

3. **Verify documentation** accuracy

4. **Check for broken links** in markdown files

## Project Structure

```
terraform-github-actions-starter/
├── .github/
│   ├── workflows/          # GitHub Actions workflows
│   ├── ISSUE_TEMPLATE/     # Issue templates
│   └── pull_request_template.md
├── docs/                   # Documentation
├── modules/               # Terraform modules
├── environments/          # Environment configurations
├── scripts/               # Utility scripts
├── CONTRIBUTING.md        # This file
├── CODE_OF_CONDUCT.md     # Code of conduct
├── SECURITY.md            # Security policy
└── CHANGELOG.md           # Version history
```

## What to Contribute

### Good First Issues

Look for issues labeled `good first issue` - these are great for newcomers!

### Areas We Need Help

- **Documentation**: Improvements, typo fixes, clarity
- **Examples**: Real-world use cases and patterns
- **Cloud Providers**: GCP support, additional Azure resources
- **CI/CD**: Workflow improvements, additional checks
- **Testing**: Integration tests, validation scripts
- **Security**: Security best practices, vulnerability scanning

## Review Process

1. **Automated checks** must pass (if configured)
2. **Code review** by maintainers
3. **Testing** in isolated environment
4. **Documentation review**
5. **Approval** and merge

### Review Timeline

- Simple fixes: 1-2 days
- New features: 3-7 days
- Major changes: 1-2 weeks

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for their contributions
- GitHub contributors page
- Release notes (for significant contributions)

## Questions?

Don't hesitate to ask questions:
- Open a [GitHub Discussion](https://github.com/iracic82/terraform-github-actions-starter/discussions)
- Comment on relevant issues
- Reach out to maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for making this project better! 🎉**
