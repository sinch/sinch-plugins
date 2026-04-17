#!/bin/bash

# Update submodule to latest version
echo "Updating sinch-skills submodule to latest version..."

# Initialize and update the submodule to the latest remote commit
git submodule update --init --remote vendor/sinch-skills

# Show the new submodule status
echo ""
echo "Submodule status:"
git submodule status

echo ""
echo "✓ Submodule updated successfully!"
echo ""
echo "To commit this change, run:"
echo "  git add vendor/sinch-skills"
echo "  git commit -m \"chore: update sinch-skills submodule\""
