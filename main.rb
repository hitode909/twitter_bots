# -*- coding: utf-8 -*-
require 'open-uri'
require 'hpricot'
require 'twitter'
require 'kconv'
require 'lib/model'
require 'pp'
require 'pit'

# TODO: レベルの閾値を動的に調整してポスト数を調整
# TODO: ロジックをmodelに移す

now = Time.now

config = Pit.get("haiku_hot_account", :require => {
    "username" => "you email in twitter",
    "password" => "your password in twitter",
  })

httpAuth = Twitter::HTTPAuth.new(config['username'], config['password'])
twitter = Twitter::Base.new(httpAuth)

doc = Hpricot(open('http://h.hatena.ne.jp/hotkeywords').read)

recents = doc.search('div.streambody > ul.cloud > li').map { |item|
  level = item.get_attribute('class').scan(/\d+$/).to_s.to_i
  anchor = item.search('a.keyword').first
  keyword = anchor.inner_text
  if level >1
    HotKeyword.create(:level =>  level, :keyword => keyword, :created => now)
  else
    nil
  end
}.compact.sort_by{ |k| k.level}.reverse

ranking = ['LIST', *recents.map{|k| k.keyword}].join(' ').toutf8
puts ranking
twitter.update ranking

recents.map{ |recent|
  { :recent => recent,
    :previous => HotKeyword.filter(:keyword => recent.keyword).filter{|k| k.created < now }.first
  }
}.map { |keyword|
  rec = keyword[:recent]
  prev = keyword[:previous]
  if !prev
    ['NEW', rec.level, rec.keyword, rec.uri].join(' ')
  elsif rec.level != prev.level
    status = rec.level > prev.level ? 'UP' : 'DOWN'
    [status, "#{prev.level}->#{rec.level}", rec.keyword, rec.uri].join(' ')
  else
    nil
  end
}.compact.each { |post|
  puts post
  twitter.update post.toutf8
}

HotKeyword.filter{|k| k.created < now }.delete
