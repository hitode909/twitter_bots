# -*- coding: utf-8 -*-
require 'pstore'
require 'tmpdir'
require 'lib/model'

# usage
if ARGV.size == 0
  raise "usage: this [RANKING, NEW]"
end

# prepare
APPLICATION = 'haiku_hot'
api = Api.new(APPLICATION)
db = PStore.new("#{Dir.tmpdir}/#{APPLICATION}")

border_level, last_hot_keywords = nil
db.transaction {
  border_level = db['border_level'] ||= 6
  last_hot_keywords = db['hot_keywords'] ||= []
}

new_keywords = HotKeyword.fetch
new_hot_keywords = new_keywords.select{ |k| k.level >= border_level}

# call
while command = ARGV.shift
  case command
  when 'NEW'
    if last_hot_keywords.size > 0
      (new_hot_keywords - last_hot_keywords).each{ |k|
        api.update ['NEW', k.keyword, k.uri].join(' ')
      }
    end
    db.transaction {
      db['hot_keywords'] = new_hot_keywords
    }
  when 'RANKING'
    ranking = new_hot_keywords.sort_by{ |k| k.level}.reverse.map{|k| k.keyword}.join(' ')
    api.update ['RANKING', ranking, HotKeyword::SOURCE_URI].join(' ')
  end
end
