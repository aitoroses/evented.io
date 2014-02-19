###
//============================================================================
// Node API
//
// Author: Aitor Oses <aitor.oses@gmail.com>
// Created: 2013/06/09
// Copyright:
//
//============================================================================
###

winston = require('winston');

log = 
  logger:
    levels:
      detail: 0
      trace: 1
      debug: 2
      enter: 3
      info: 4
      warn: 5
      error: 6  
    colors:
      detail: 'grey'
      trace: 'white'
      debug: 'blue'
      enter: 'inverse'
      info: 'green'
      warn: 'yellow'
      error: 'red'

getLogger = ->
  logger = new (winston.Logger)(
    transports: [
      new (winston.transports.Console)(
        level: 'enter'
        colorize: true
      )
    # ,
    #   new (winston.transports.File)(
    #     filename: 'logs/logging-file.log'
    #   )
    ]
  )

  logger.setLevels(log.logger.levels)
  winston.addColors(log.logger.colors)

  return logger

module.exports = getLogger()