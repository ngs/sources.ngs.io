Dotenv.load

###
# Blog settings
###

lang = (ENV['MM_LANG'] || 'ja').to_sym
cname = ({
  en: 'ngs.io',
  ja: 'ja.ngs.io'
})[lang]

Time.zone = "Tokyo"

activate :directory_indexes
activate :syntax
activate :i18n, langs: [lang]

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :autolink => true
set :build_dir,    "build-#{lang}"

activate :blog do |blog|
  blog.permalink = "{year}/{month}/{day}/{title}/index.html"
  blog.sources = "#{lang}/{year}-{month}-{day}-{title}.html"
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
    fb: data.send(lang).ogp.fb,
    og: data.send(lang).ogp.og
  }
  ogp.blog = true
  ogp.base_url = "http://#{cname}/"
end

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash, ignore: 'images'
  ignore '.DS_Store'
  ignore '.*.swp'
  if lang == :en
    ignore '/about/index.ja.html'
    ignore '/ja/*'
    activate :google_analytics do |ga|
      ga.tracking_id = 'UA-200187-32'
    end
  else
    ignore '/about/index.en.html'
    ignore '/en/*'
    activate :google_analytics do |ga|
      ga.tracking_id = 'UA-200187-34'
    end
  end
end

activate :disqus do |d|
  d.shortname = lang == :en ? "ngsio" : "jangsio"
end

activate :deploy do |deploy|
  IO.write "source/CNAME", cname
  deploy.method = :git
  deploy.branch = 'gh-pages'
  deploy.remote = "https://#{ENV['GH_TOKEN']}@github.com/ngs/#{cname}.git"
end
