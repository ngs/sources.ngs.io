#= require 'jquery'
#= require 'bootstrap'


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

$ ->
  $('[data-toggle=tooltip]').tooltip()
  $('form#tag-filter-form')
  .on('submit', no)
  .find('input:text')
  .on('keyup', handleFilterTagsKeyUp)

