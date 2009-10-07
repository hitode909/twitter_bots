# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/../modules/bot2ch/')
$:.unshift(File.dirname(__FILE__) + '/../lib/')
require 'bot2ch'
require 'pstore'
require 'tmpdir'
require 'sanitize'
require 'cgi'
require 'api'

def shorturl url
  open('http://to.ly/api.php?longurl=' + url).read
rescue
  open('http://is.gd/api.php?longurl=' + url).read
rescue
  url
end

def shortbody text
  if text.split(//).length > 100
    text.split(//)[0..100].join + '…'
  else
    text
  end
end

def escape_body body
  CGI.unescapeHTML(body.gsub(/<[^>]*>/,'')).strip.gsub(/\s+|　/, ' ')
end

APPLICATION = '2ch_watch'
api = Api.new(APPLICATION)
db = PStore.new("#{Dir.tmpdir}/#{APPLICATION}")

menu = Bot2ch::Menu.new
board = menu.get_board '/net/'
threads = board.threads.select{|th| th.title =~ /Twitter/}
threads.each{ |th|
  db.transaction {
    last_fetched = db[th.dat_no]
    next if th.posts.length == last_fetched
    from = last_fetched ? last_fetched + 1 : 0
    th.posts[from..-1].each { |post|
      api.update "#{post.index}: #{shortbody(escape_body(post.body))} #{shorturl(post.url)}"
    }
    db[th.dat_no] = th.posts.length
  }
}
