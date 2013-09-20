class BH.Views.SuggestionsView extends Backbone.View
  template: BH.Templates['suggestions']

  className: 'suggestions suggestions_view'

  events:
    'click li': 'onTagClicked'

  initialize: ->
    @collection.on 'remove', @render, @
    @collection.on 'add', @render, @

  render: ->
    html = Mustache.to_html(@template, tags: @collection.pluck('name'))
    @$el.hide()
    @$el.html html
    @

  onTagClicked: (ev) ->
    @trigger 'click:tag', $(ev.currentTarget).data('tag')

  show: ->
    @$el.show()

  hide: ->
    @$el.hide()

  moveDown: ->
    $activeTags = @$('li.active')
    $selected = @$('.selected')

    if $selected.length > 0
      index = $activeTags.indexOf($selected[0]) + 1
      if index != $activeTags.length
        $selected.removeClass('selected')
        $selected = $activeTags.eq(index)
        $selected.addClass('selected')
    else
      $selected = $activeTags.eq(0)
      $selected.addClass('selected')

  moveUp: ->
    $activeTags = @$('li.active')
    $selected = @$('.selected')

    if $selected.length > 0
      index = $activeTags.indexOf($selected[0])
      if index != 0
        $selected.removeClass('selected')
        $selected = $activeTags.eq(index - 1)
        $selected.addClass('selected')

  selectedTag: ->
    $selected = @$('.selected')
    $selected.data('tag')

  filterBy: (text) ->
    hiddenTags = 0
    @$('li').each ->
      if $(this).data('tag').match(text)
        $(this).addClass('active')
      else
        hiddenTags += 1
        $(this).removeClass('active')

    if hiddenTags == @collection.length then @hide() else @show()

