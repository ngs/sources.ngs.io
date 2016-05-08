xml.instruct!
xml.rss(
    'version' => '2.0',
    'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
    'xmlns:wfw' => 'http://wellformedweb.org/CommentAPI/',
    'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
    'xmlns:atom' => 'http://www.w3.org/2005/Atom',
    'xmlns:sy' => 'http://purl.org/rss/1.0/modules/syndication/',
    'xmlns:slash' => 'http://purl.org/rss/1.0/modules/slash/') do
  xml.channel do
    site_url = t('blog.url')
    xml.title t('blog.title')
    xml.tag!('atom:link', 'href' => URI.join(site_url, 'rss.xml'), 'rel' => 'self', 'type' => 'application/rss+xml')
    xml.tag!('atom:link', 'href' => URI.join(site_url, 'feed.xml'), 'type' => 'application/atom+xml')
    xml.language I18n.locale.to_s
    xml.description t('blog.description')
    xml.link URI.join(site_url, blog.options.prefix.to_s)
    xml.lastBuildDate(blog.articles.first.date.to_time.rfc822) unless blog.articles.empty?

    blog.articles[0..9].each do |article|
      xml.item do
        xml.title article.title
        xml.link URI.join(site_url, article.url)
        xml.guid URI.join(site_url, article.url)
        xml.pubDate article.date.to_time.rfc822
        xml.author "a@ngs.io (#{t('author.name')})"
        # xml.summary article.summary, "type" => "html"
        xml.description Sanitize.clean(article.body, :elements => %w{p strong ul li h1 h2})
      end
    end
  end
end
