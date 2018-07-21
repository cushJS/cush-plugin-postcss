evalFile = require 'cush/utils/evalFile'
path = require 'path'
log = require 'lodge'

sourceMaps =
  inline: false
  annotation: false
  sourcesContent: false

module.exports = ->
  postcss = require 'postcss'

  # TODO: watch `postcss.config.js` for changes
  @hook 'package', (pack) ->
    if config = evalFile path.join(pack.path, 'postcss.config.js')
      config.to = ''
      config.map = sourceMaps
      pack.postcss = config
      return config

  @transform '.css', (asset, pack) =>
    if config = pack.postcss
      config = Object.create config
      config.from = @relative asset.path

      postcss(config.plugins)
        .process(asset.content, config)
        .then (result) ->

          result.warnings().forEach (msg) ->
            log.warn msg + " (#{asset.path})"

          content: result.css
          map: result.map.toJSON()
