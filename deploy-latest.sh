#!/bin/zsh

# Automated deployment script for Wolf-recovery
# This script finds the latest HTML file and deploys it as index.html

REPO_DIR="/Users/manuelescolano/Documents/APPS/Wolf-recovery"
cd "$REPO_DIR" || exit 1

echo "🔍 Finding the latest HTML file..."

# Find the most recently modified HTML file (excluding index.html)
LATEST_FILE=$(ls -t Wolf-Recovery_*.html 2>/dev/null | head -n 1)

if [ -z "$LATEST_FILE" ]; then
    echo "❌ No Wolf-Recovery HTML files found!"
    exit 1
fi

echo "📄 Latest file found: $LATEST_FILE"

# Check if index.html exists
if [ -f "index.html" ]; then
    # Generate backup name with timestamp
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_NAME="index_backup_${TIMESTAMP}.html"
    
    echo "💾 Backing up current index.html as $BACKUP_NAME"
    mv index.html "$BACKUP_NAME"
    
    # Add backup to git
    git add "$BACKUP_NAME"
fi

# Copy latest file to index.html
echo "📋 Copying $LATEST_FILE to index.html"
cp "$LATEST_FILE" index.html

# Add the new index.html
git add index.html

# Also add the latest file if it's not already tracked
git add "$LATEST_FILE"

# Commit changes
echo "💬 Committing changes..."
git commit -m "Deploy latest version: $LATEST_FILE

Co-Authored-By: Warp <agent@warp.dev>"

# Push to GitHub
echo "🚀 Pushing to GitHub..."
git push

echo "✅ Deployment complete!"
echo "🔗 Check Vercel for deployment status..."

# Wait a moment and check Vercel deployment
sleep 5
vercel ls --cwd "$REPO_DIR"
