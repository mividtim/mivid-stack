turtles
  a.getTurtles(href="#") Get Turtles
  br
  img(src="loading.gif", class="{hidden: !state.turtles.isFetching}")
  table(class="{hidden: state.turtles.isFetching || turtles.length === 0}")
    thead
      tr
        th Name
        th Herd
    tbody
      tr(each="{turtles}")
        td {name}
        td {herdId}
  style(scoped).
    .hidden
      display: none
  script.
    @mixin "subscribe"
    @state = @store.getState()
    @turtles = @state.turtles.items
    @on "mount", ->
      @root.querySelector("a.getTurtles").addEventListener "click", (event) =>
        event.preventDefault()
        @store.dispatch @actions.turtles.getAll()