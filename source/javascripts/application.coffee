#= require 'jquery'
#= require 'jquery.cookie'
#= require 'bootstrap'
#= require 'konami'

COOKIE_KEY_THEME = 'ngs.io.theme'
$.cookie.json = yes
themeCookieOptions = expires: 30, path: '/'
themeCookieOptions.domain = '.ngs.io' if /^(?:ja\.)?ngs\.io$/.test document.location.hostname
themes = null
hours = new Date().getHours()
defaultTheme = if hours > 4 and hours < 18
  cssCdn: "http://netdna.bootstrapcdn.com/bootswatch/latest/united/bootstrap.min.css"
  name: "United"
  preview: "http://bootswatch.com/united/"
  isDefault: yes
else
  cssCdn: "http://netdna.bootstrapcdn.com/bootswatch/latest/cyborg/bootstrap.min.css"
  name: "Cyborg"
  preview: "http://bootswatch.com/cyborg/"
  isDefault: yes
theme = $.cookie(COOKIE_KEY_THEME) || defaultTheme
document.write """<link rel="stylesheet" type="text/css" href="#{theme.cssCdn}" id="bootswatch-css">"""

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

loadThemeDropDown = ->
  $.get('http://api.bootswatch.com/3/')
  .done (res)->
    ul = $('.bootswatch-theme-list').empty()
    for { cssCdn, name, preview } in res.themes
      li = $ """<li><a href="#{preview}" target="_blank">#{name}</a></li>"""
      li.find('a').data { cssCdn, name, preview }
      ul.append li

setTheme = (theme)->
  { name, preview, cssCdn, isDefault } = theme
  $('.bootswatch-theme-name').text name
  $('.bootswatch-link').text(name).attr 'href', preview
  link = $ 'link#bootswatch-css'
  if link.attr('href') isnt cssCdn
    link.attr 'href', cssCdn
  unless isDefault
    $.cookie COOKIE_KEY_THEME, theme, themeCookieOptions

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
  setTheme theme
  window.addEventListener 'shake', shakeEventDidOccur, no

new Konami () ->
  $('#sidebar-bootswatch').fadeIn()
