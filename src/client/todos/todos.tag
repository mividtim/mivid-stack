todos
  add_todo
  visible_todo_list
  filter_link_list
  style(scoped).
    :scope
      font-size: 150%
    li.completed
      text-decoration: line-through
add_todo
  form
    input
    input(type="submit", value="Add Todo")
  script.
    @mixin "subscribe"
    @on "mount", ->
      @root.querySelector("form").addEventListener "submit", (event) =>
        event.preventDefault()
        @store.dispatch @performers.todos.add @root.querySelector("input").value
visible_todo_list
  ul
    todo(each="{visibleTodos}", on_click="{parent.onClick}", completed="{completed}", text="{text}", id="{id}")
  script.
    @mixin "subscribe"
    state = @store.getState()
    @visibleTodos = (todo for todo in state.todos.list when \
      state.todos.filter is "SHOW_ALL" or \
      state.todos.filter is "SHOW_ACTIVE" and !todo.completed or \
      state.todos.filter is "SHOW_COMPLETED" and todo.completed)
    @onClick = (id) => @store.dispatch @performers.todos.toggle id
todo
  li(class="{completed: opts.completed}") {opts.text}
  script.
    @on "mount", => @root.querySelector("li").addEventListener "click", -> opts.on_click opts.id
filter_link_list
  span Show:
  filter_link(filter="SHOW_ALL", text="All")
  filter_link(filter="SHOW_ACTIVE", text="Active")
  filter_link(filter="SHOW_COMPLETED", text="Completed")
filter_link
  disableable_link(enabled="{opts.filter !== todosFilter}", text="{opts.text}", on_click="{onClick}")
  script.
    @mixin "subscribe"
    @todosFilter = @store.getState().todos.filter
    @onClick = => @store.dispatch @performers.todos.setFilter opts.filter