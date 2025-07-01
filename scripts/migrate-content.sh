#!/bin/bash
set -e

echo "Migrating Middleman content to Hugo..."

# Function to convert a single file
convert_file() {
    local src_file="$1"
    local lang="$2"
    local dest_dir="/Users/ngs/src/sources.ngs.io/content/$lang/posts"
    
    # Extract filename without extension
    local basename=$(basename "$src_file" | sed 's/\.html\.md.*$//')
    local dest_file="$dest_dir/$basename.md"
    
    echo "Converting: $src_file -> $dest_file"
    
    # Copy file and convert front matter format if needed
    cp "$src_file" "$dest_file"
    
    # Convert .html.md.erb to .md and update any ERB syntax if needed
    # This is a basic conversion - you may need to adjust based on your ERB usage
}

# Create destination directories
mkdir -p content/ja/posts content/en/posts

# Convert Japanese content
echo "Converting Japanese content..."
for file in source/ja/*.html.md*; do
    if [[ -f "$file" ]]; then
        convert_file "$file" "ja"
    fi
done

# Convert English content  
echo "Converting English content..."
for file in source/en/*.html.md*; do
    if [[ -f "$file" ]]; then
        convert_file "$file" "en"
    fi
done

# Copy static assets
echo "Copying static assets..."
cp -r source/images themes/custom/static/ 2>/dev/null || true
cp -r source/stylesheets themes/custom/assets/css/ 2>/dev/null || true
cp -r source/javascripts themes/custom/assets/js/ 2>/dev/null || true

# Copy other pages
echo "Copying other pages..."
mkdir -p content/ja content/en

# Copy about pages
if [[ -f source/about/index.ja.html.slim ]]; then
    echo "---" > content/ja/about.md
    echo "title: 自己紹介" >> content/ja/about.md
    echo "---" >> content/ja/about.md
    echo "" >> content/ja/about.md
    echo "<!-- TODO: Convert Slim template content -->" >> content/ja/about.md
fi

if [[ -f source/about/index.en.html.slim ]]; then
    echo "---" > content/en/about.md
    echo "title: About" >> content/en/about.md
    echo "---" >> content/en/about.md
    echo "" >> content/en/about.md
    echo "<!-- TODO: Convert Slim template content -->" >> content/en/about.md
fi

echo "Content migration complete!"
echo "Note: You may need to manually adjust ERB syntax and Slim templates."