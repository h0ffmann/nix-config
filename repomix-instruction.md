# Using AI Tools with NixOS Configuration

Working with NixOS configuration files requires careful attention to detail, especially when using AI assistants. While AI tools can provide valuable help with configuration tasks, they require human supervision to ensure system stability and functionality.

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
4. **Build Testing**: Test your changes with `nixos-rebuild build --flake .` before switching.

### Safe Testing Process

Follow this process for safely testing AI-suggested changes:

```bash
# 1. Commit current working state
git add .
git commit -m "Before AI changes: working configuration"

# 2. Apply AI changes to files

# 3. Validate syntax
nix flake check

# 4. Test build without applying
sudo nixos-rebuild build --flake "$(pwd)"

# 5. If successful, apply changes
sudo nixos-rebuild switch --flake "$(pwd)"

# 6. If something breaks, rollback
sudo nix-env --profile /nix/var/nix/profiles/system --rollback
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## Common AI Pitfalls with NixOS

- **Missing Dependencies**: AI may forget to include all necessary dependencies
- **Incorrect Package Names**: AI might suggest packages with slightly wrong names
- **Outdated Syntax**: AI may use deprecated NixOS options or patterns
- **Module Conflicts**: AI might not recognize conflicts between modules

## Troubleshooting AI-Related Issues

If you encounter issues after applying AI-suggested changes:

1. **Check Build Errors**: Look carefully at the error messages for clues
2. **Partial Application**: If only certain parts of the configuration work, isolate the problematic sections
3. **Compare with Previous Version**: Use `git diff` to identify exactly what changed
4. **Rollback When Needed**: Don't hesitate to rollback to a known working state using the instructions in the "NixOS Rollback Instructions" section

Remember that AI tools are assistants, not replacements for understanding your NixOS configuration. Always review changes carefully, especially for critical system components.