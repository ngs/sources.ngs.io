#= require 'jquery'
#= require 'jquery.cookie'
#= require 'jquery.hidescroll'
#= require 'bootstrap'
#= require 'konami'
#= require 'shake'
#= require 'time-elements'
#= require 'suncalc'
#= require 'underscore'

COOKIE_KEY_THEME = 'ngs.io.theme'
$.cookie.json = yes
themeCookieOptions = expires: 30, path: '/'
themeCookieOptions.domain = '.ngs.io' if /^(?:ja\.)?ngs\.io$/.test document.location.hostname
themes = null

getDefaultTheme = ->
  date = new Date()
  {sunset, sunrise} = SunCalc.getTimes date, 35.6216798, 139.6993775
  defaultTheme = if date > sunrise and date < sunset
    cssCdn: "https://netdna.bootstrapcdn.com/bootswatch/3.3.7/united/bootstrap.min.css"
    name: "United"
    preview: "http://bootswatch.com/united/"
    isDefault: yes
  else
    cssCdn: "https://netdna.bootstrapcdn.com/bootswatch/3.3.7/darkly/bootstrap.min.css"
    name: "Darkly"
    preview: "http://bootswatch.com/darkly/"
    isDefault: yes

shakeEventDidOccur = (e)->
  if $.cookie(COOKIE_KEY_THEME) and confirm 'Reset style?'
    $.removeCookie COOKIE_KEY_THEME, themeCookieOptions
    document.location.reload()

handleFilterTagsKeyUp = (e)->
  input = $ e.target
  filterTags input.val()

filterTags = (text)->
  $('#sidebar-tags-list > li').each ->
    self = $ @
    if self.text().indexOf(text) == -1
      self.addClass 'hidden'
    else
      self.removeClass 'hidden'

setUpMixCloud = ->
  $('.mixcloud[data-embed-uuid]').each ->
    ele = $ @
    { embedUuid, feed } = ele.data()
    light = $('body').css('background-color') is 'rgb(255, 255, 255)'
    src = "https://www.mixcloud.com/widget/iframe/?feed=#{ encodeURIComponent feed }&amp;embed_uuid=#{ embedUuid }&amp;replace=0&amp;light=#{light}&amp;hide_cover=1&amp;embed_type=widget_standard&amp;hide_tracklist=1"
    ele.replaceWith $('<iframe width="100%" height="180" frameborder="0" />').attr {src}

handleShowAllLink = (e)->
  $('#sidebar-tags-list > li').removeClass 'hidden'
  $('.show-all-tags-link').remove()

handleReadMoreLink = (e)->
  link = $ @
  link.button 'loading'
  href = link.attr 'href'
  $.get(href)
  .done (res)->
    res = $ res
    articleBody = link.parents('.entry').find('.article-body')
    title = res.find('title').text()
    content = res.find('[role=main] .article-body').html()
    articleBody.html content
    history.pushState null, title, href
    ga 'send', 'pageview', {
      page: "#{href}?inline=1"
      title: title
    }
    link.remove()
    setUpMixCloud()
  no

loadThemeDropDown = ->
  $.get('https://bootswatch.com/api/3.json')
  .done (res)->
    ul = $('.bootswatch-theme-list').empty()
    appendItem ul, {
      cssCdn: '//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css'
      preview: 'http://bootswatch.com/default/'
      name: 'Default'
    }
    appendItem ul, data for data in res.themes
    appendItem ul, {
      cssCdn: '/stylesheets/bootstrap/bootstra386.css'
      preview: 'https://kristopolous.github.io/BOOTSTRA.386/'
      name: 'BOOTSTRA.386'
    }

appendItem = (ul, data)->
  { cssCdn, name, preview } = data
  li = $ """<li><a href="#{preview}" target="_blank">#{name}</a></li>"""
  li.find('a').data data
  ul.append li
  li

setTheme = (theme)->
  { name, preview, cssCdn, isDefault } = theme
  $('.bootswatch-theme-name').text name
  $('.bootswatch-link').text(name).attr 'href', preview
  link = $ 'link#bootswatch-css'
  if link.attr('href') isnt cssCdn
    link.attr 'href', cssCdn
  unless isDefault
    $.cookie COOKIE_KEY_THEME, theme, themeCookieOptions
  bgColor = $('body').css 'background-color'
  if m = bgColor.match /rgb\((\d+),\s*(\d+),\s*(\d+)\s*\)/
    [str, r, g, b] = m
    bgColor = "rgba(#{r}, #{g}, #{b}, 0.9)"
  $('#sidebar-navigation').css 'background-color', bgColor

handleYAuctionLink = (e) ->
  anchor = $ e.target
  href = anchor.attr 'href'
  anchor.attr 'href', "http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2462325&pid=883185139&vc_url=#{encodeURIComponent href}"

$ ->
  $('body').on 'click', '[href*="auction"][href*="yahoo.co.jp"]', handleYAuctionLink
  $('[data-toggle=tooltip]').tooltip()
  $('form#tag-filter-form')
  .on('submit', no)
  .find('input')
  .on('keyup', handleFilterTagsKeyUp)
  $('.article-body > table').addClass 'table-bordered table'
  $('.show-all-tags-link').on('click', handleShowAllLink)
  $('#sidebar-bootswatch [data-toggle="dropdown"]').on 'click', loadThemeDropDown
  $('.bootswatch-theme-list').on 'click', 'a', ->
    setTheme $(@).data()
    no
  $('.read-more a').on 'click', handleReadMoreLink
  setTheme theme
  window.addEventListener 'shake', shakeEventDidOccur, no
  $('#sidebar-navigation').hidescroll hiddenClass: 'nav-hidden'
  setUpMixCloud()

hexDigits = _.map [0..15], (n) -> n.toString 0x10
hex = (x) -> if isNaN(x) then '00' else hexDigits[(x - x % 16) / 16] + hexDigits[x % 16]
rgb2hex = (rgb) ->
  if m = rgb?.match /^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/
    "##{hex m[1]}#{hex m[2]}#{hex m[3]}"
  else
    ''

window.setupAmazonWidget = (title = '　', asin...) ->
  unless asin?.length > 0
    asin = $.unique($('a[href*="amazon.co.jp"]').map(-> $(@).attr('href').match(/\/gp\/product\/(\w+)\//)?[1])).get()
  body = $ 'body'
  bg = rgb2hex body.css 'background-color'
  fg = rgb2hex body.css 'color'
  link = rgb2hex $('a[href]').css 'color'

  window.amzn_wdgt = {
    widget: 'MyFavorites'
    tag: 'ngsio-22'
    columns: '1'
    rows: '100'
    title: title
    width: '290'
    ASIN: asin.join(',')
    showImage: 'True'
    showPrice: 'True'
    showRating: 'False'
    shuffleProducts: 'False'
    design: '2'
    colorTheme: 'White'
    headerTextColor: '#666'
    marketPlace: 'JP'
    outerBackgroundColor: bg,
    innerBackgroundColor: bg,
    backgroundColor: bg
    borderColor: bg
    headerTextColor: fg
    linkedTextColor: link
    bodyTextColor: fg
  }

new Konami () ->
  $('#sidebar-bootswatch').fadeIn()

theme = $.cookie(COOKIE_KEY_THEME) || getDefaultTheme()
document.write """<link rel="stylesheet" type="text/css" href="#{theme.cssCdn}" media="screen" id="bootswatch-css">"""
