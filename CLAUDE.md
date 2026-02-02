# DataPass Development Guide

## Build/Test/Lint Commands

**IMPORTANT**: This project supports both Docker and non-Docker environments.

### With Docker (recommended)
Always use `make` commands - they handle Docker setup including Chrome for tests:
- Run server: `make up`
- Run all tests: **`make tests`**
- Run specific test: `make tests spec/path/to/file_spec.rb:LINE_NUMBER`
- Run E2E tests: `make e2e` or `make e2e features/path/to/file.feature:LINE_NUMBER`
- Run linter: `make lint`
- Fix linting issues: `make fix-lint`
- JS linting: `make js-lint`

### Without Docker (local development)
If the user is NOT using Docker, you can use these commands directly:
- Run server: `bin/local_run.sh`
- Run all tests: `bundle exec rspec`
- Run specific test: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Run E2E tests: `bundle exec cucumber features/path/to/file.feature:LINE_NUMBER`
- Run linter: `bundle exec rubocop`
- Fix linting issues: `bundle exec rubocop -A`
- JS linting: `standard app/javascript`

**Ask the user which environment they're using if unclear**, or check for running Docker containers.

## Code Style Guidelines

- Ruby version: 3.4.1
- Uses Ruby on Rails conventions
- String literals: single quotes preferred (`'string'`)
- Maximum method length: 15 lines
- Class length: max 150 lines
- Indentation: 2 spaces
- Naming: snake_case for methods/variables, CamelCase for classes
- Controllers should be RESTful when possible
- JavaScript follows StandardJS conventions
- Always use inline modules for namespacing : `class A::B::C` instead of `module
    A; module B; class C`
- When creating components, always create a preview within
    `spec/components/previews`
- Do not use FactoryBot within components previews, use real objects, you can
    find actual objects within seeds.
- DO NOT use comments, use meaningful variables and methods names
- All files should end with a newline
- Use apostrophe (’) instead of single quote (') within text content
- Use french quotes (« ») instead of double quotes (") within text content

## Testing Guidelines

- Use RSpec expectations syntax for tests
- Test files should follow the same structure as the application
- Do not test associations and validations directly, focus on behavior
- Never use controller specs if you can use cucumber features, if controller
  specs are needed, check if you can create organizers or services to
  handle the logic

## Implementation Guidelines

- Always implement features in the following order:
  1. Implement models and their tests
  2. Implement services (preferably organizers) and their tests
  3. Implement controllers with their views
  4. Implement cucumnber features

  At each step, ensure that the tests pass before moving to the next step.

- You can ask questions about the instructions if it not clear enough or if
  you think it will help me deepen my thinking.
- Use TDD, refactor your code after each test. Use `rubocop` to check you
  code style. Make it consistent with the rest of the codebase.
- Be sure that rubocop passes before stopping your work.
- Be sure that tests you introduce pass before stopping your work.
- Authorization should be done in the controller, not in the model/services.
- Check docs/ for technical documentation if needed.
- For building forms use DSFRFormBuilder
- Components are documented here
    https://www.systeme-de-design.gouv.fr/version-courante/fr/composants

## Git

- When you move files, use `git mv` to keep history.
