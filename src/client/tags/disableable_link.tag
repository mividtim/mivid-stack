disableable_link
  span(if="{!opts.enabled}") {opts.text}
  a(if="{opts.enabled}", href="{opts.href || '#'}") {opts.text}
  script.
    @mixin "context"
    if opts.on_click?
      @on "mount", =>
        @root.querySelector("a")?.addEventListener "click", (event) ->
          event.preventDefault()
          opts.on_click()