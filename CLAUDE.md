# DataPass Development Guide

## Build/Test/Lint Commands

- Run server: `bin/local_run.sh` or with Docker: `make up`
- Run all tests: `bundle exec rspec` or `make tests`
- Run specific test: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- Run specific E2E test: `bundle exec cucumber features/path/to/file.feature:LINE_NUMBER`
- Run linter: `bundle exec rubocop` or `make lint`
- Fix linting issues: `bundle exec rubocop -A` or `make fix-lint`
- JS linting: `standard app/javascript` or `make js-lint`

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
- DO NOT use comments, use meaningful variables and methods names
- All files should end with a newline

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

## Git

- When you move files, use `git mv` to keep history.
