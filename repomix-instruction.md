Working with NixOS configuration files requires careful attention to detail, especially when using AI assistants. While AI tools can provide valuable help with configuration tasks, they require human supervision to ensure system stability and functionality.

## Research

Research NixOS best practices and provide the most up-to-date information.
## AI Assistance Guidelines

### General Precautions

- **Incremental Changes**: Make small, focused changes and rebuild rather than attempting large refactors all at once.
- **Version Control**: Always commit working configurations before making AI-suggested changes.
- **Understand Before Applying**: Ensure you understand what each change does before implementing it.
- **Validate Outputs**: AI may hallucinate features or syntax that doesn't exist in NixOS.

### Working with Critical Files

When modifying system-critical files like `flake.nix`, `configuration.nix`, or `hardware-configuration.nix`:

1. **Preserve Functionality**: Ensure AI-suggested changes maintain all existing functionality.
2. **Check References**: Verify that all file imports, module references, and package names remain correct.
3. **Validate Syntax**: Use `nix flake check` before rebuilding to catch syntax errors.
