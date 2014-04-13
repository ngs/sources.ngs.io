###
# Blog settings
###

Time.zone = "Tokyo"

activate :directory_indexes
activate :syntax
activate :i18n, langs: [:en]

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :autolink => true

activate :blog do |blog|
  blog.permalink = "{year}/{month}/{day}/{title}/index.html"
  blog.sources = "en/{year}-{month}-{day}-{title}.html"
  blog.taglink = "t/{tag}/index.html"
  blog.layout = "article"
  blog.summary_separator = /(READMORE)/
  blog.summary_length = 250
  blog.year_link = "{year}/index.html"
  blog.month_link = "{year}/{month}/index.html"
  blog.day_link = "{year}/{month}/{day}/index.html"
  blog.default_extension = ".md"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "p{num}"
end

page "/feed.xml",    layout: false
page "/sitemap.xml", layout: false
page "/404.html",    directory_index: false

compass_config do |config|
  config.output_style = :compact
end

require 'haml'
require 'sass'
require 'coffee-script'

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :development do
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-XXXXXX-YY'
  end
end

activate :ogp do |ogp|
  ogp.namespaces = {
    fb: data.en.ogp.fb,
    og: data.en.ogp.og
  }
  ogp.blog = true
  ogp.base_url = 'http://ngs.io/'
end

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash, ignore: 'images'
  ignore '.DS_Store'
  ignore '.*.swp'
  ignore '/about/index.ja.html'
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-200187-32'
  end
end

activate :disqus do |d|
  d.shortname = "ngsio"
end

activate :deploy do |deploy|
  IO.write "source/CNAME", "ngs.io"
  deploy.method = :git
  deploy.branch = 'gh-pages'
  deploy.remote = "https://#{ENV['GH_TOKEN']}@github.com/ngs/ngs.io.git"
end
