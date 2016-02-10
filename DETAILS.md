### Required Tools

The only two things you need to install to start development on this framework are
[Node.js](https://nodejs.org/en/) (which includes the command-line package-management utility "npm"), and the [Chrome "LiveReload" extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en).  Optionally, the [Brackets](http://brackets.io/) editor is pretty solid, and you would just want the [Jade Preprocessor Fork](https://github.com/joepie91/jade-brackets) plugin for syntax highlighting (which is actually easier to install from File->Extension Manager directly in the Brackets application).  A .brackets.json file is included, which tells Brackets to understand
.tag files as Jade templates.  This allows for pretty robust syntax highlighting of .tag files.

### Installing Dependencies

From command-line in the folder, after fetching the repo, all dependencies are installed by simply running "npm install" which installs all declared dependencies in package.json, so that's the first file to review.  All packages (and their downstream dependencies) are installed into node_modules.

### Build Process

Next comes the build tool, which npm just installed for you.  "npm run dev" will look up "dev" in "scripts" in the package.json, which in turn runs the "gulp" command from node_modules (since it's not in your path), passing it "dev".  "gulp" looks up "dev" at the very bottom of gulpfile.coffee, so that is the next file to review.  "gulp dev" does a whole bunch of stuff, which amounts to:

* Deleting any previous build
* Building the entire app (service and client) into output folder "build/"
* Starting a "watch" on the output folder, and recompiling any edited files going forward
* Starting "nodemon" which runs the web service, and re-starts the service if any files there change.  Service runs on port 8000, and is responsible for serving the client application, which is all compiled to static files in the "client" subdirectory of build/
* Opens the localhost:8000 in a new browser tab in your default browser, which opens "build/client/index.html," which is compiled from "src/client/index.jade."  The index turn loads up "build/client/index.js" which is compiled from "src/client/index.coffee" which bootstraps the client app in your browser
* Starts a "livereload" service, which the browser extension uses to detect any changes in "build/client" and either injecting the changes into the browser (static files), or reloading the page (JS files, including compiled page templates)

So, literally all this magic happens by simply installing Node and a Chrome extension, and running two commands "npm install" (first time only), and "npm run dev" any time you want to do development.

### Architecture

All source code for the app itself is contained in "src."

The "service" is a work in progress, but here is the intended framework. app.js runs Express (which serves the static files) and starts RethinkdbWebsocketService, a Websocket server which handles RethinkDB requests from attached clients.  The client subscribes to this service with RethinkdbWebsocketClient, which looks and feels exactly like the Node.js (server-side) client, except tunnels the request through the Websocket so the service executes the request.  All database code (reads and writes) is actually contained directly in the client application, and whitelisted in the service (I'll pull that code out of app.js at the appropriate time).  The whitelist performs any validations needed on the reads or writes (including row- and column-level authorization and throttling).

In the future, I would like to prevent direct writes to the database from either the client or the service.  Instead, RethinkDB will act as a materialized view of an immutable log of actions, an architecture inspired by [this article](http://www.confluent.io/blog/turning-the-database-inside-out-with-apache-samza/).  Instead, all write requests will be made as dispatched Redux actions, whose reducer will in turn dispatch actions to the server through a well-defined application-level (not framework level) REST API.  The API implementation contained in the service will in turn dispatch the actions to Apache Kafka, which will keep an immutable log of all actions ever performed by all clients and services. Apache Samza will be used to define reducers that consume the Kafka stream (starting with the first-ever dispatched action, or from the last snapshot) in real-time, updating the current global, mutable application state in the RethinkDB that the application client queries (through the whitelisted queries in the service). After passing through this pipe, the service will detect that the change applies to the client who made the change (and any others with access to watch it), and push the updated query result to the appropriate client(s).

### Deployment

Out of the box, this stack includes automated deployment to [Heroku](http://www.heroku.com).  The Heroku endpoint is defined near the top of the gulpfile, under "urls."  Pushing to your test Heroku server is done with simply "npm run heroku."  From there, set up a [pipeline](https://devcenter.heroku.com/articles/pipelines) to promote the application to production.