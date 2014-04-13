###
# Blog settings
###

Time.zone = "Tokyo"

activate :directory_indexes
activate :syntax
activate :i18n, langs: [:ja]

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :autolink => true

activate :blog do |blog|
  blog.permalink = "{year}/{month}/{day}/{title}/index.html"
  blog.sources = "ja/{year}-{month}-{day}-{title}.html"
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
    fb: data.ja.ogp.fb,
    og: data.ja.ogp.og
  }
  ogp.blog = true
  ogp.base_url = 'http://ja.ngs.io/'
end

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  ignore '.DS_Store'
  ignore '.*.swp'
  ignore '/about/index.en.html'
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-200187-34'
  end
end

activate :disqus do |d|
  d.shortname = "jangsio"
end

activate :deploy do |deploy|
  IO.write "source/CNAME", "ja.ngs.io"
  deploy.method = :git
  deploy.branch = 'gh-pages'
  deploy.remote = "https://#{ENV['GH_TOKEN']}@github.com/ngs/ja.ngs.io.git"
end
