rdb
  a.queryTurtles(href="#") Query Turtles
  script.
    @mixin "context"
    @on "mount", ->
      @root.querySelector("a.queryTurtles").addEventListener "click", (event) =>
        event.preventDefault()
        @store.dispatch @actions.rdb.getAll()