# GitHub Copilot Instructions for Battlestation

## Project Overview

Battlestation is a personal development environment setup tool that automates the configuration of macOS/Unix development workstations. It manages dotfiles, installs development tools via Homebrew, sets up shell configurations, and creates symlinks for configuration files.

## Architecture & Components

### Core Components
- **Ruby CLI Application**: Main entry point (`bin/battlestation`) with modular CLI class
- **Shell Scripts**: Legacy setup scripts and utilities (`bin/setup`, shell functions)
- **Configuration Management**: Dotfiles and environment configurations (`config/`)
- **Utility Scripts**: Helper tools for anonymizing files, managing symlinks (`script/`)

### Key Directories
```
bin/           # Executable scripts and main CLI entry point
config/        # Dotfiles and configuration templates
  dotfiles/    # Shell configurations (zshrc, zshenv, aliases, etc.)
lib/           # Ruby library code and modules
script/        # Utility scripts for various tasks
spec/          # RSpec test files
src/           # Additional source files
```

## Development Guidelines

### Ruby Code Style
- Follow Ruby community conventions and the existing codebase patterns
- Use `frozen_string_literal: true` pragma in all Ruby files
- Prefer explicit over implicit returns
- Use meaningful variable and method names
- Follow existing error handling patterns using custom utilities

### Code Organization Patterns
- **CLI Pattern**: Main logic in `lib/battlestation/cli.rb` with method-based subcommands
- **Output Utilities**: Use `lib/output.rb` for consistent user messaging with colors
- **System Integration**: Shell command execution patterns using `system` with bash `-c`
- **File Operations**: Use Ruby File/FileUtils operations, following existing symlink patterns

### Shell Script Conventions
- Use bash with proper error handling (`set -e` where appropriate)
- Follow existing function naming with descriptive names like `install_homebrew`
- Use readonly variables for paths and configuration
- Implement proper error messaging using color codes via `tput`

### Configuration Management
- Symlink-based configuration with source/target path patterns
- Environment-specific configuration loading (work vs home)
- Machine architecture detection (Silicon Mac vs Intel Mac)
- Path management with proper precedence ordering

## Testing Practices

### RSpec Configuration
- Use standard RSpec practices with descriptive test names
- Follow existing file helper patterns for test file creation
- Maintain test isolation and cleanup
- Use mock/stub patterns for system command testing when appropriate

### Test Structure
- Unit tests for Ruby classes and modules
- Integration tests for CLI commands and system operations
- File system operation testing using temporary directories
- Use existing `FileHelper` module for test file creation

## Development Workflow

### Dependencies & Setup
- Ruby version specified in `.ruby-version` (currently 2.7.6)
- Bundler for gem management with Gemfile dependencies
- RSpec for testing (`bundle exec rspec`)
- Rubocop for linting (`bundle exec rubocop`)

### Key Dependencies
- `colorize` for terminal output styling
- `aws-sdk-s3` for cloud storage operations
- `rake` for task automation
- `rspec` for testing framework

### File Management Patterns
- Use absolute paths when working with system configurations
- Implement proper permission checking before file operations
- Follow existing symlink validation patterns
- Handle missing files and directories gracefully

## Common Operations

### Adding New Configuration
1. Add source file to `config/dotfiles/` or appropriate subdirectory
2. Update symlink creation logic in setup scripts
3. Consider environment-specific variations
4. Update documentation and help text

### Adding New CLI Commands
1. Add method to `lib/battlestation/cli.rb`
2. Follow existing patterns for system command execution
3. Add appropriate error handling and user feedback
4. Write tests for new functionality

### Working with System Commands
- Use `system 'bash', '-c', %{...}` pattern for complex shell operations
- Check exit status with `$?.exitstatus`
- Provide meaningful error messages for command failures
- Consider cross-platform compatibility where applicable

## Environment Considerations

### macOS Specifics
- Homebrew installation and management (Intel vs Apple Silicon paths)
- defaults write commands for system preferences
- Application-specific configurations (VS Code, Xcode)
- LaunchAgent plist file management

### Shell Environment
- zsh as primary shell with custom configurations
- PATH management for multiple development tools
- History and completion settings
- Git integration and prompt customization

## Security & Privacy

### Data Handling
- Implement anonymization features for sensitive data
- Avoid hardcoding personal information in configurations
- Use secure patterns for handling credentials and tokens
- Consider privacy implications when adding new features

When contributing to this project, ensure changes maintain the existing patterns and support the goal of creating a reproducible, automated development environment setup.