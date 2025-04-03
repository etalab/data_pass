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
- Test files should follow the same structure as the application
- Use RSpec expectations syntax for tests
- JavaScript follows StandardJS conventions
- DO NOT use comments, use meaningful variables and methods names
- All files should end with a newline
