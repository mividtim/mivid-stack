layout
  display: flex
  header
    .logo
    span Mivid Stack
    span Tim
  aside
    nav
      ul
        li
          a(href="#") Home
        li
          a(href="#todos") Todos
  section.main
  style(scoped).
    primaryColor = #330044
    header, footer
      height: 150px
      font-size: 300%
      background-color: primaryColor
      color: white
      display: flex
      flex-direction: row
      align-items: center
      padding: 0 20px
      .logo
        width: 120px
        height: 120px
        background-image: url(stock-vector-vector-tribal-decorative-echidna-isolated-animal-on-transparent-background-zentangle-style-314494664.png)
        background-size: contain
        background-position: center
        background-repeat: no-repeat
      span
        margin-left: 10px
    aside
      position: absolute
      top: 180px
      left: 0
      width: 150px
      background-color: white
    .main
      position: absolute
      top: 180px
      left: 180px
      background-color: white
      padding: 30px
    .buttons
      display: flex
      flex-flow: row wrap
      justify-content: space-around    
      align-content: center
      font-size: 250%
    .medium
      font-size: 350%
    .large
      font-size: 450%
    .button
      flex: 1
      display: flex;
      justify-content: center
      align-content: center
      align-items: center
      text-align: center
      margin: 20px
      background-color: primaryColor
      border-radius: 20px
      color: white
      font-weight: bold
      font-family: sans-serif
      border: 4px lightgrey solid