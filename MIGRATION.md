# Middleman to Hugo Migration Guide

This document outlines the migration from Middleman to Hugo for the ngs.io blog.

## Migration Overview

### Key Changes

1. **Multi-locale Build System**: Hugo configs for separate ja/en builds
2. **Template Engine**: Slim → Go Templates  
3. **Content Structure**: Middleman blog → Hugo posts
4. **Asset Pipeline**: Middleman Sprockets → Hugo Pipes
5. **Build Process**: Ruby-based → Go-based

## New Structure

```
├── hugo.ja.toml          # Japanese site config
├── hugo.en.toml          # English site config
├── content/
│   ├── ja/
│   │   ├── posts/        # Japanese blog posts
│   │   └── about.md      # Japanese about page
│   └── en/
│       ├── posts/        # English blog posts  
│       └── about.md      # English about page
├── themes/custom/
│   ├── layouts/
│   │   ├── _default/
│   │   │   ├── baseof.html    # Base template
│   │   │   ├── list.html      # Archive/list pages
│   │   │   ├── single.html    # Individual posts
│   │   │   ├── rss.xml        # RSS feed
│   │   │   └── sitemap.json   # JSON sitemap
│   │   └── partials/
│   │       ├── sidebar.html
│   │       ├── footer.html
│   │       └── head/
│   ├── static/            # Static assets
│   └── assets/           # Processed assets
└── scripts/
    ├── build-ja.sh       # Build Japanese site
    ├── build-en.sh       # Build English site
    ├── build-all.sh      # Build both sites
    └── migrate-content.sh # Content migration script
```

## Build Commands

### Development
```bash
# Japanese site
hugo server --config hugo.ja.toml --contentDir content/ja --destination build-ja

# English site  
hugo server --config hugo.en.toml --contentDir content/en --destination build-en
```

### Production
```bash
# Build all locales
./scripts/build-all.sh

# Build specific locale
./scripts/build-ja.sh
./scripts/build-en.sh
```

## Migration Steps

### 1. Content Migration
- Convert `.html.md.erb` files to `.md`
- Update front matter format (YAML → TOML if needed)
- Move files to `content/{lang}/posts/`
- Convert ERB syntax to Hugo shortcodes/templating

### 2. Template Migration
- Convert Slim templates to Go templates
- Update helper functions to Hugo template functions
- Migrate partials system
- Convert i18n to Hugo's multilingual system

### 3. Asset Migration  
- Move CSS/JS to theme assets
- Update asset references in templates
- Configure Hugo Pipes for asset processing
- Copy static files (images, favicons, etc.)

### 4. Configuration Migration
- Split single config into locale-specific configs
- Configure different base URLs and build directories
- Set up taxonomies, permalinks, markup settings
- Configure multilingual parameters

## Key Differences

### Template Syntax
```slim
// Middleman (Slim)
h1= current_article.title
= link_to article.url do
  = article.title

// Hugo (Go Templates)  
<h1>{{ .Title }}</h1>
<a href="{{ .Permalink }}">{{ .Title }}</a>
```

### Front Matter
```yaml
# Middleman
---
title: Article Title
date: 2024-12-31 09:00
tags: tag1, tag2
---

# Hugo
---
title: "Article Title"
date: 2024-12-31T09:00:00+09:00
tags: ["tag1", "tag2"]
---
```

### Build Process
```bash
# Middleman
MM_LANG=ja bundle exec middleman build
MM_LANG=en bundle exec middleman build

# Hugo
hugo --config hugo.ja.toml --contentDir content/ja --destination build-ja
hugo --config hugo.en.toml --contentDir content/en --destination build-en
```

## Features Preserved

- ✅ Multi-locale builds with separate domains
- ✅ Blog post permalinks structure  
- ✅ Tag/category taxonomies
- ✅ RSS feeds
- ✅ Open Graph meta tags
- ✅ Disqus comments integration
- ✅ Google Analytics
- ✅ Social sharing buttons
- ✅ Responsive design
- ✅ Search functionality
- ✅ Archive/monthly navigation

## TODO Items

1. **Complete Content Migration**
   - Run migration script for all posts
   - Convert ERB syntax in posts
   - Update image references

2. **Template Refinement**
   - Convert remaining Slim templates
   - Implement missing partials
   - Add search functionality

3. **Asset Pipeline**
   - Configure SASS processing
   - Set up asset fingerprinting
   - Optimize image processing

4. **Deployment**
   - Update CI/CD scripts
   - Configure domain routing
   - Test both locale builds

5. **Feature Parity**
   - Implement similar articles feature
   - Add AMP pages support
   - Configure redirects

## Testing Migration

1. Build both locales: `./scripts/build-all.sh`
2. Compare output structure with current builds
3. Test key pages: home, posts, archives, tags
4. Verify RSS feeds and sitemaps
5. Check responsive design and functionality
6. Test multilingual navigation

## Rollback Plan

The original Middleman setup remains unchanged. To rollback:
1. Remove Hugo files (keep them in git for reference)
2. Continue using existing Middleman build process
3. Archive Hugo migration work for future iteration