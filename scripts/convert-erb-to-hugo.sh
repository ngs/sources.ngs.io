#!/bin/bash
set -e

echo "Converting ERB content to Hugo format..."

# Function to convert a single file
convert_erb_file() {
    local src_file="$1"
    local lang="$2"
    local dest_dir="/Users/ngs/src/sources.ngs.io/content/$lang/posts"
    
    # Extract filename without extension
    local basename=$(basename "$src_file" | sed 's/\.html\.md.*$//')
    local dest_file="$dest_dir/$basename.md"
    
    echo "Converting ERB: $src_file -> $dest_file"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Copy and convert the file
    cp "$src_file" "$dest_file"
    
    # Convert front matter
    sed -i '' '
        # Convert date format
        s/date: \([0-9-]*\) \([0-9:]*\)/date: \1T\2:00+09:00/g
        
        # Quote title and description
        s/^title: \(.*\)/title: "\1"/g
        s/^description: \(.*\)/description: "\1"/g
        
        # Convert tags to array format
        s/^tags: \(.*\)/tags: ["\1"]/g
        s/", "/", "/g
        s/, /", "/g
    ' "$dest_file"
    
    # Convert ERB partials to shortcodes or inline content
    sed -i '' '
        # Convert partial includes to shortcode format
        s|<%= partial '\''partials/\([^'\'']*\)'\'' %>|{{< partial "\1" >}}|g
        
        # Convert READMORE to Hugo more comment
        s/READMORE/<!--more-->/g
        
        # Convert simple ERB expressions (this is basic - may need manual review)
        s|<%= \([^%]*\) %>|{{ \1 }}|g
    ' "$dest_file"
    
    echo "Converted: $dest_file"
}

# Function to extract and convert partials
extract_partials() {
    local src_file="$1"
    local partial_path="$2"
    
    # Create partials directory structure
    local partial_dir=$(dirname "$partial_path")
    mkdir -p "content/partials/$partial_dir"
    
    # Copy partial content
    local partial_dest="content/partials/$partial_path"
    
    # Remove code block markers and convert to plain content
    sed '
        # Remove opening code block markers
        /^```/d
        # Remove trailing empty lines
        /^[[:space:]]*$/d
    ' "$src_file" > "$partial_dest"
    
    echo "Extracted partial: $partial_dest"
}

# Convert specific ERB patterns
convert_erb_patterns() {
    local file="$1"
    
    # Create temporary file for processing
    local temp_file=$(mktemp)
    
    # Process the file line by line for complex ERB patterns
    while IFS= read -r line; do
        case "$line" in
            *"<%= partial"*)
                # Extract partial path and convert to shortcode
                partial_path=$(echo "$line" | sed "s/.*partial '\\([^']*\\)'.*/\\1/")
                echo "{{< partial \"$partial_path\" >}}" >> "$temp_file"
                ;;
            *"<%= link_to"*)
                # Convert link_to helpers (basic conversion)
                echo "<!-- TODO: Convert link_to helper manually -->" >> "$temp_file"
                echo "$line" >> "$temp_file"
                ;;
            *)
                echo "$line" >> "$temp_file"
                ;;
        esac
    done < "$file"
    
    # Replace original file
    mv "$temp_file" "$file"
}

# Main conversion process
main() {
    echo "Starting ERB to Hugo conversion..."
    
    # Create necessary directories
    mkdir -p content/{ja,en}/posts content/partials content/code-snippets
    
    # Convert Japanese files
    echo "Converting Japanese files..."
    for file in source/ja/*.html.md.erb; do
        if [[ -f "$file" ]]; then
            convert_erb_file "$file" "ja"
        fi
    done
    
    # Convert English files
    echo "Converting English files..."
    for file in source/en/*.html.md.erb; do
        if [[ -f "$file" ]]; then
            convert_erb_file "$file" "en"
        fi
    done
    
    # Process partials
    echo "Processing partials..."
    for partial in source/partials/**/*.html.md; do
        if [[ -f "$partial" ]]; then
            # Extract relative path
            rel_path=$(echo "$partial" | sed 's|source/partials/||')
            extract_partials "$partial" "$rel_path"
        fi
    done
    
    # Post-process converted files for complex ERB patterns
    echo "Post-processing converted files..."
    for file in content/{ja,en}/posts/*.md; do
        if [[ -f "$file" ]]; then
            convert_erb_patterns "$file"
        fi
    done
    
    echo "ERB conversion complete!"
    echo ""
    echo "Manual review needed for:"
    echo "- Complex ERB expressions"
    echo "- link_to helpers"
    echo "- Custom helper methods"
    echo "- Dynamic content generation"
    echo ""
    echo "Use Hugo shortcodes for complex templating:"
    echo "- {{< code lang=\"ruby\" >}}...{{< /code >}}"
    echo "- {{< partial \"path/to/partial\" >}}"
    echo "- {{< param \"variable_name\" >}}"
}

# Run main function
main "$@"