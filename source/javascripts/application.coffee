#= require 'jquery'
#= require 'jquery.cookie'
#= require 'bootstrap'
#= require 'konami'

COOKIE_KEY_THEME = 'ngs.io.theme'
$.cookie.json = yes
themeCookieOptions = expires: 30, path: '/'
themeCookieOptions.domain = '.ngs.io' if /^(?:ja\.)?ngs\.io$/.test document.location.hostname
themes = null
defaultTheme =
  cssCdn: "http://netdna.bootstrapcdn.com/bootswatch/latest/united/bootstrap.min.css"
  name: "United"
  preview: "http://bootswatch.com/united/"
theme = $.cookie(COOKIE_KEY_THEME) || defaultTheme
document.write """<link rel="stylesheet" type="text/css" href="#{theme.cssCdn}" id="bootswatch-css">"""

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
  { name, preview, cssCdn } = theme
  $('.bootswatch-theme-name').text name
  $('.bootswatch-link').text(name).attr 'href', preview
  link = $ 'link#bootswatch-css'
  if link.attr('href') isnt cssCdn
    link.attr 'href', cssCdn
  $.cookie COOKIE_KEY_THEME, theme

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

new Konami () ->
  $('#sidebar-bootswatch').fadeIn()
