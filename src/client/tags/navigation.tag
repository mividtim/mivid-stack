navigation
  aside
    nav
      ul
        li(class="{selected: route === ''}")
          disableable_link(enabled="{route !== ''}", text="Home", href="#")
        li(class="{selected: route === 'todos'}")
          disableable_link(enabled="{route !== 'todos'}", text="Todos", href="#todos")
        li(class="{selected: route === 'turtles'}")
          disableable_link(enabled="{route !== 'turtles'}", text="Turtles", href="#turtles")
  style(scoped).
    ul
      padding: 0 20px
      list-style-type: none
    li
      padding: 5px
    li.selected
        background-color: lightgrey
    a
      text-decoration: none
      color: black
  script.
    @mixin "subscribe"
    @route = @store.getState().route