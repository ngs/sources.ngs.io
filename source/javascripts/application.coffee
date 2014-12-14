#= require 'jquery'
#= require 'jquery.cookie'
#= require 'bootstrap'
#= require 'konami'
#= require 'shake'
#= require 'time-elements'
#= require 'suncalc'

COOKIE_KEY_THEME = 'ngs.io.theme'
$.cookie.json = yes
themeCookieOptions = expires: 30, path: '/'
themeCookieOptions.domain = '.ngs.io' if /^(?:ja\.)?ngs\.io$/.test document.location.hostname
themes = null

getDefaultTheme = ->
  date = new Date()
  {sunset, sunrise} = SunCalc.getTimes date, 35.6216798, 139.6993775
  defaultTheme = if date > sunrise and date < sunset
    cssCdn: "http://netdna.bootstrapcdn.com/bootswatch/latest/united/bootstrap.min.css"
    name: "United"
    preview: "http://bootswatch.com/united/"
    isDefault: yes
  else
    cssCdn: "http://netdna.bootstrapcdn.com/bootswatch/latest/darkly/bootstrap.min.css"
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
  no

loadThemeDropDown = ->
  $.get('http://api.bootswatch.com/3/')
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

$ ->
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

new Konami () ->
  $('#sidebar-bootswatch').fadeIn()

theme = $.cookie(COOKIE_KEY_THEME) || getDefaultTheme()
document.write """<link rel="stylesheet" type="text/css" href="#{theme.cssCdn}" id="bootswatch-css">"""
