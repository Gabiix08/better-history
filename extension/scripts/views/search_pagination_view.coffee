class BH.Views.SearchPaginationView extends BH.Views.MainView
  @include BH.Modules.I18n
  @include BH.Modules.Url

  className: 'search_pagination_view'
  template: BH.Templates['search_pagination']

  initialize: ->
    @chromeAPI = chrome
    @results = @options.results
    @query = @options.query
    @pages = BH.Lib.Pagination.calculatePages(@results)

    if @model.get('page') > @pages
      @model.set page: 1

  events:
    'click .pagination a': 'onPageClicked'

  render: ->
    properties =
      # Hide pagination if there is only one page of results
      paginationClass: if @pages == 1 then 'hidden' else ''

    properties.pages = for i in [1..@pages] by 1
      url: "#{@urlFor('search', @query)}/p#{i}"
      className: if i == @model.get('page') then 'selected' else ''
      number: i

    properties = _.extend(@getI18nValues(), properties)
    html = Mustache.to_html @template, properties
    @$el.html html

  onPageClicked: (ev) ->
    $el = $(ev.currentTarget)
    analyticsTracker.paginationClick()

    router.navigate($el.attr('href'))

    @$('a').removeClass('selected')
    $el.addClass('selected')

    @model.set page: $el.data('page')

  getI18nValues: ->
    properties = []
    properties['i18n_number_of_visits'] = @t('number_of_visits', [
      @results
    ])
    properties
