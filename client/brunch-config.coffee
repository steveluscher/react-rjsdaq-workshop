exports.config =

  plugins:
    react:
      autoIncludeCommentBlock: yes

  files:
    javascripts:
      joinTo: 'app.js'
    stylesheets:
      joinTo: 'app.css'

  modules:
    nameCleaner: (path) ->
      path
        # Strip the client/ prefix from module names
        .replace(/^app\//, '')

        # Strip the .jsx extension from module names
        .replace(/\.jsx/, '')
