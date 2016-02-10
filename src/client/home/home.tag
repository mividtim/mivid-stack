home
  include:marked ./README.md
  h1
    a.toggleDetails(href="#") Details
  div.details(class="{hidden: hideDetails}")
    include:marked ./DETAILS.md
  style(scoped).
    div.details.hidden
      display: none
  script.
    @mixin "subscribe"
    @hideDetails = @store.getState().home.details is "HIDE"
    @on "mount", ->
      @root.querySelector("a.toggleDetails").addEventListener "click", (event) =>
        event.preventDefault()
        @store.dispatch @performers.home.toggleDetails()