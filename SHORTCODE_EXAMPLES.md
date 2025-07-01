# Hugo Shortcode Examples for ERB-like Functionality

## Basic Shortcodes

### Images
```markdown
<!-- ERB-like in Middleman -->
![](2024-12-31-shokan2024/main.jpg)

<!-- Hugo shortcode -->
{{< image "2024-12-31-shokan2024/main.jpg" "2024年の写真" >}}
```

### Links with Special Handling
```markdown
<!-- ERB-like with tag links -->
[所感](/t/所感/)

<!-- Hugo with render hook (automatic) -->
[所感](/t/所感/)

<!-- Or explicit shortcode -->
{{< tag-link "所感" >}}
```

### External Links
```markdown
<!-- Hugo shortcode -->
{{< link "https://ins0.jp/news/modelmap-analyzer" "Modelmap Analyzer のニュース" >}}
```

## Advanced Usage

### Using Page Parameters
```yaml
---
title: "記事タイトル"
companies:
  enkake: "https://enkake.co.jp/"
  instance0: "https://ins0.jp/"
---
```

```markdown
<!-- In content -->
今年は {{< param "companies.enkake" >}} での開発を続けています。
```

### Dynamic Content
```markdown
<!-- Current year -->
今年は {{< param "date" | dateFormat "2006" >}} 年でした。

<!-- Site info -->
このサイトは {{< param "site.title" >}} です。
```

### Conditional Content
```hugo
{{< if-param "locale" "ja" >}}
日本語コンテンツ
{{< else >}}
English content
{{< /if-param >}}
```

## Migration Strategy

1. **Automatic**: Use render hooks for standard Markdown (links, images)
2. **Manual**: Convert ERB expressions to shortcodes
3. **Hybrid**: Keep simple HTML, use shortcodes for complex logic

### Common ERB → Hugo Patterns

```erb
<!-- ERB -->
<%= link_to article.url do %>
  <%= article.title %>
<% end %>

<!-- Hugo shortcode -->
{{< article-link slug="article-slug" >}}
```

```erb
<!-- ERB -->
<% if current_article.tags.include?('tech') %>
  Tech article content
<% end %>

<!-- Hugo -->
{{ if in .Params.tags "tech" }}
  Tech article content
{{ end }}
```

## Processing Existing ERB Files

For bulk conversion, you could:

1. Create a preprocessing script that converts ERB to shortcodes
2. Use Hugo's content adaptation hooks
3. Gradually migrate files as you edit them

Example preprocessing:
```bash
# Convert ERB links to shortcodes
sed 's/<%= link_to \([^,]*\), \([^%]*\) %>/{{< link \1 \2 >}}/g'
```