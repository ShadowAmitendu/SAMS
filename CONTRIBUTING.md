# Contributing to SAMS

Thank you for your interest in contributing to **SAMS (Smart Attendance Management System)**.

Contributions are welcome, whether they involve fixing bugs, improving existing functionality, suggesting new features, improving documentation, or reporting issues.

Please read the following guidelines before contributing.

## Getting Started

1. Fork the [SAMS repository](../../fork).
2. Clone your fork to your local machine.

```bash
git clone https://github.com/YOUR_USERNAME/SAMS.git
```

3. Navigate to the project directory.

```bash
cd SAMS
```

4. Create a new branch for your contribution.

```bash
git checkout -b feature/your-feature-name
```

## Branch Naming Convention

Use descriptive branch names to keep development organized.

| Prefix | Purpose | Example |
| ------ | ------- | ------- |
| `feature/` | New functionality | `feature/qr-attendance` |
| `fix/` | Bug fixes | `fix/login-validation` |
| `docs/` | Documentation changes | `docs/update-readme` |
| `refactor/` | Code restructuring | `refactor/attendance-service` |
| `test/` | Adding or updating tests | `test/attendance-api` |
| `chore/` | Maintenance tasks | `chore/update-dependencies` |

## Commit Message Convention

Write clear and meaningful commit messages.

Recommended format:

```text
<type>: <short description>
```

Examples:

```text
feat: add student registration
fix: resolve QR code validation issue
docs: update project documentation
refactor: improve attendance service
test: add attendance API tests
chore: update dependencies
```

Common commit types:

- `feat` – New feature.
- `fix` – Bug fix.
- `docs` – Documentation changes.
- `refactor` – Code improvements without changing functionality.
- `test` – Test-related changes.
- `chore` – Maintenance and configuration changes.

## Development Guidelines

Please follow these guidelines when contributing:

- Write clean, readable, and maintainable code.
- Follow the existing project structure and coding conventions.
- Use meaningful variable, method, and class names.
- Avoid unnecessary code duplication.
- Validate user inputs appropriately.
- Handle exceptions and errors properly.
- Do not commit passwords, API keys, database credentials, or other sensitive information.
- Update documentation whenever functionality changes.
- Add appropriate tests for new features and bug fixes.

## Pull Request Guidelines

Before submitting a Pull Request:

1. Ensure your changes work as expected.
2. Test your implementation.
3. Check for unnecessary files and debugging statements.
4. Update relevant documentation.
5. Commit your changes using meaningful commit messages.
6. Push your branch to your fork.

```bash
git add .
git commit -m "feat: add your feature"
git push origin feature/your-feature-name
```

Then:

1. Open the original SAMS repository.
2. Click **New Pull Request**.
3. Select your branch.
4. Provide a clear title and description.
5. Explain what you changed and why.
6. Submit your Pull Request for review.

## Reporting Bugs

If you discover a bug:

- Check whether the issue has already been reported.
- Open a new GitHub Issue.
- Provide a clear description of the problem.
- Include steps to reproduce the issue.
- Attach screenshots or error logs when relevant.
- Mention the affected module or functionality.

For security vulnerabilities, please follow the instructions in [SECURITY.md](SECURITY.md) instead of creating a public issue.

## Feature Requests

Have an idea that could improve SAMS?

1. Check existing issues and discussions.
2. Open a Feature Request.
3. Explain the proposed functionality.
4. Describe the problem it solves.
5. Include examples or screenshots where applicable.

Feature requests are subject to review and project requirements.

## Code of Conduct

All contributors are expected to maintain a respectful and professional environment.

- Be respectful towards other contributors.
- Accept constructive feedback.
- Avoid personal attacks and inappropriate language.
- Focus discussions on improving the project.
- Help maintain an inclusive and collaborative environment.

## Questions and Support

For questions, suggestions, or project-related discussions, use the repository's GitHub Issues or Discussions section, where available.

---

Thank you for contributing to **SAMS – Smart Attendance Management System**.

Every contribution helps improve the project.
