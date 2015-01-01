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
activate :livereload
activate :emoji, :dir => '/images/emoji', :width => 20, :height => 20

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :autolink => true, :tables => true
set :build_dir,    "build-#{lang}"
set :partials_dir, 'partials'
set :site_url, "http://#{cname}"

activate :blog do |blog|
  blog.permalink = "{year}/{month}/{day}/{title}/index.html"
  blog.sources = "#{lang}/{year}-{month}-{day}-{title}.html"
  blog.taglink = "t/{tag}/index.html"
  blog.layout = "article"
  blog.summary_separator = /(READMORE)/
  blog.summary_length = 500
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
# if lang == :en
activate :similar, :algorithm => :'word_frequency/tree_tagger'
# else
#   activate :similar, :algorithm => :'word_frequency/mecab'
# end


page "/feed.xml",    layout: false
page "/sitemap.xml", layout: false
page "/404.html",    directory_index: false

require 'slim'
require 'sass'
require 'coffee-script'

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

compass_config do |config|
  config.output_style = :compact
end

ready do
  sprockets.append_path '/lib/javascripts/'
  sprockets.append_path '/lib/stylesheets/'

  def redirect_to path, res
    proxy path, 'redirect.html', locals: { url: res.url }, layout: false
  end
  sitemap.resources.each do|res|
    if res.is_a? Middleman::Blog::BlogArticle
      redirect_to "blog#{res.url.sub(%r{/$}, '.html')}", res
      redirect_to "blog#{res.url}index.html", res
    elsif res.url.match %r{^/p\d+/$}
      redirect_to "blog#{res.url.sub(%r{p(\d)}, 'page/\1')}index.html", res
    elsif res.url.match %r{^/t/(.+)/$}
      redirect_to "blog#{res.url.sub(%r{t/(.+)}, 'categories/\1')}index.html", res
    elsif res.url.match %r{^/20(\d{2}[\d/]+)/$}
      redirect_to "blog#{res.url}index.html", res
    end
  end
end

configure :development do
  activate :google_analytics do |ga|
    ga.tracking_id = 'UA-XXXXXX-YY'
  end
end

activate :ogp do |ogp|
  ogp.namespaces = {
    fb: data.send(lang).ogp.fb,
    og: data.send(lang).ogp.og,
    twitter: data.send(lang).ogp.twitter
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
  ignore '_drafts'
  ignore 'redirect.html'
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
  activate :favicon_maker, :icons => {
    "favicon-hires.png" => [
      { icon: "apple-touch-icon-152x152-precomposed.png" },
      { icon: "apple-touch-icon-144x144-precomposed.png" },
      { icon: "apple-touch-icon-120x120-precomposed.png" },
      { icon: "apple-touch-icon-114x114-precomposed.png" },
      { icon: "apple-touch-icon-76x76-precomposed.png" },
      { icon: "apple-touch-icon-72x72-precomposed.png" },
      { icon: "apple-touch-icon-60x60-precomposed.png" },
      { icon: "apple-touch-icon-57x57-precomposed.png" },
      { icon: "apple-touch-icon-precomposed.png", size: "57x57" },
      { icon: "apple-touch-icon.png", size: "57x57" },
      { icon: "favicon-196x196.png" },
      { icon: "favicon-160x160.png" },
      { icon: "favicon-96x96.png" },
      { icon: "mstile-144x144", format: "png" }
    ],
    "favicon-lores.png" => [
      { icon: "favicon-32x32.png" },
      { icon: "favicon-16x16.png" },
      { icon: "favicon.png", size: "16x16" },
      { icon: "favicon.ico", size: "64x64,32x32,24x24,16x16" }
    ]
  }
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

helpers do

  def alt_lang
    I18n.locale.to_s == 'en' ? "ja_JP" : "en_US"
  end

  def alt_lang_name
    I18n.locale.to_s == 'en' ? "日本語" : "English"
  end

  def alt_host
    I18n.locale.to_s == 'en' ? "ja.ngs.io" : "ngs.io"
  end

  def alt_href
    "http://#{alt_host}#{current_resource.url}"
  end

  def alt_link
    link_to %Q{<span class="glyphicon glyphicon-globe"></span>&nbsp;#{alt_lang_name}},
      alt_href, href_lang: alt_lang, rel: "alternate"
  end

end
