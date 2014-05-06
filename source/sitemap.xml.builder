xml.instruct!
xml.urlset 'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  site_url = t 'blog.url'
  xml.url do
    xml.loc site_url
    xml.lastmod blog.articles.first.date.to_time.iso8601
    xml.changefreq "daily"
    xml.priority "1.0"
  end
  xml.url do
    xml.loc URI.join(site_url, '/archives/')
    xml.lastmod blog.articles.first.date.to_time.iso8601
    xml.changefreq "daily"
    xml.priority "0.8"
  end
  xml.url do
    xml.loc URI.join(site_url, '/about/')
    xml.lastmod blog.articles.first.date.to_time.iso8601
    xml.changefreq "daily"
    xml.priority "0.8"
  end
  blog.articles.each do |article|
    xml.url do
      xml.loc URI.join(site_url, article.url)
      xml.lastmod article.date.to_time.iso8601
      xml.changefreq "never"
      xml.priority "0.8"
    end
  end
  blog.tags.each do |tag, articles|
    xml.url do
      xml.loc URI.join(site_url, URI.escape(tag_path(tag)))
      xml.lastmod (articles.size > 0 ? articles.first.date : Date.today).to_time.iso8601
      xml.changefreq "daily"
      xml.priority "0.5"
    end
  end
  blog.articles.select {|a| a.data[:public] }.group_by {|a| a.date.year }.each do |year, year_articles|
    xml.url do
      xml.loc URI.join(site_url, blog_year_path(year))
      xml.lastmod (year_articles.size > 0 ? year_articles.first.date : Date.today).to_time.iso8601
      xml.changefreq year == Date.today.year ? "daily" : "never"
      xml.priority "0.3"
    end
    year_articles.group_by {|a| a.date.month }.each do |month, month_articles|
      xml.url do
        xml.loc URI.join(site_url, blog_month_path(year, month))
        xml.lastmod (month_articles.size > 0 ? month_articles.first.date : Date.today).to_time.iso8601
        xml.changefreq month == Date.today.month && year == Date.today.year ? "daily" : "never"
        xml.priority "0.3"
      end
      month_articles.group_by {|a| a.date.day }.each do |day, day_articles|
        xml.url do
          xml.loc URI.join(site_url, blog_day_path(year, month, day))
          xml.lastmod (day_articles.size > 0 ? day_articles.first.date : Date.today).to_time.iso8601
          xml.changefreq day == Date.today.day && month == Date.today.month && year == Date.today.year ? "daily" : "never"
          xml.priority "0.3"
        end
      end
    end
  end
end
