# DataPass Development Guide

## Build/Test/Lint Commands

- Run specific test: `docker compose run --rm web bundle exec rspec spec/path/to/file_spec.rb`
- Run specific E2E test: `docker compose run --rm web bundle exec cucumber features/path/to/file.feature`
- Fix linting issues:  `make fix-lint`
- Fix JS linting: `standard app/javascript` or `make fix-js-lint`

## Code Style Guidelines

- Ruby version: 3.4.1
- Uses Ruby on Rails conventions
- String literals: single quotes preferred (`'string'`)
- Maximum method length: 15 lines
- Class length: max 150 lines
- Indentation: 2 spaces
- Naming: snake_case for methods/variables, CamelCase for classes
- Controllers should be RESTful when possible
- Test files should follow the same structure as the application
- Use RSpec expectations syntax for tests
- JavaScript follows StandardJS conventions
- DO NOT use comments, use meaningful variables and methods names
- All files should end with a newline

## Caillou's agent Guidelines

- Always use docker to run the tests. And you don't need to stop the pg and redis services before.
- Always run a specific test file, never the whole test suite
- Always respect the lint rules when you write code
- DRY (Don't Repeat Yourself) : Factorise your code as much as possible
- Ask for details : If the task is too vague, ask for clarifications before writing
- You can also stop in the middle of your work and ask for clarifications when needed