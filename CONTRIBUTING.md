# Contributing to Secure Notes App

Thank you for considering contributing to the Secure Notes App! This document outlines the process for contributing to the project and provides guidelines to help you get started.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [How to Contribute](#how-to-contribute)
4. [Development Workflow](#development-workflow)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Documentation](#documentation)
8. [Submitting Pull Requests](#submitting-pull-requests)
9. [Review Process](#review-process)

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Git

### Setting Up the Development Environment

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```
   git clone https://github.com/yourusername/secure_note_app.git
   ```
3. Add the original repository as a remote:
   ```
   git remote add upstream https://github.com/originalowner/secure_note_app.git
   ```
4. Install dependencies:
   ```
   flutter pub get
   ```
5. Run the app:
   ```
   flutter run
   ```

## How to Contribute

There are many ways to contribute to the project:

- **Report bugs**: If you find a bug, please create an issue with detailed information about how to reproduce it.
- **Suggest features**: If you have an idea for a new feature, create an issue to discuss it.
- **Improve documentation**: Help improve the documentation by fixing typos, adding examples, or clarifying explanations.
- **Write code**: Contribute bug fixes or new features by submitting pull requests.

## Development Workflow

1. **Create a branch**: Create a new branch for your changes
   ```
   git checkout -b feature/your-feature-name
   ```
   or
   ```
   git checkout -b fix/your-bug-fix
   ```

2. **Make changes**: Make your changes to the codebase

3. **Test your changes**: Ensure your changes work as expected and don't break existing functionality

4. **Commit your changes**: Use clear and descriptive commit messages
   ```
   git commit -m "Add feature: your feature description"
   ```
   or
   ```
   git commit -m "Fix: description of the bug you fixed"
   ```

5. **Push to your fork**:
   ```
   git push origin feature/your-feature-name
   ```

6. **Create a pull request**: Submit a pull request from your branch to the main repository

## Coding Standards

The project follows the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo). Additionally:

- Use meaningful variable and function names
- Write comments for complex logic
- Follow the clean architecture principles
- Keep functions small and focused on a single task
- Use proper error handling

### Code Formatting

Run the following command before submitting your code:

```
flutter format .
```

### Static Analysis

Run the following command to check for potential issues:

```
flutter analyze
```

## Testing Guidelines

All new code should include appropriate tests:

- **Unit tests**: For business logic, repositories, and use cases
- **Widget tests**: For UI components
- **Integration tests**: For feature workflows

Run tests with:

```
flutter test
```

Aim for high test coverage, especially for critical functionality like authentication and data storage.

## Documentation

Good documentation is essential for the project:

- Add comments to your code where necessary
- Update existing documentation if your changes affect it
- Document new features or changes in behavior
- Include examples for complex functionality

## Submitting Pull Requests

When submitting a pull request:

1. Fill out the pull request template completely
2. Reference any related issues
3. Describe what your changes do and why they should be included
4. Include screenshots or GIFs for UI changes
5. Ensure all tests pass
6. Make sure your code is properly formatted

## Review Process

All pull requests will be reviewed by project maintainers. The review process includes:

1. Checking that the code follows the project's coding standards
2. Verifying that the changes work as expected
3. Ensuring that appropriate tests are included
4. Checking that documentation is updated

Reviewers may request changes before merging your pull request. This is a normal part of the collaborative development process.

## Feature Requests

If you have ideas for new features:

1. Check if the feature has already been requested or discussed
2. Create a new issue describing the feature
3. Explain why the feature would be valuable
4. Outline how the feature might be implemented

## Bug Reports

When reporting bugs:

1. Use the bug report template
2. Include detailed steps to reproduce the bug
3. Describe the expected behavior
4. Describe the actual behavior
5. Include screenshots if applicable
6. Provide information about your environment (Flutter version, device, etc.)

## Communication

- **Issues**: Use GitHub issues for bug reports and feature requests
- **Discussions**: Use GitHub discussions for questions and general discussion
- **Pull Requests**: Use pull requests for code contributions

## License

By contributing to this project, you agree that your contributions will be licensed under the project's license.

Thank you for contributing to the Secure Notes App!
