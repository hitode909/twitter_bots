$:.unshift(File.dirname(__FILE__) + '/../modules/bot2ch/')
require 'bot2ch'
require 'pstore'
require 'tmpdir'

APPLICATION = '2ch_watch'
api = Api.new(APPLICATION)

