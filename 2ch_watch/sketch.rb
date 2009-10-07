# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/../modules/bot2ch/')
require 'pp'
require 'bot2ch'

menu = Bot2ch::Menu.new
board = menu.get_board('/net/')
threads = board.threads.select{|th| th.title =~ /Twitter/}

p threads.first
puts threads.first.url
puts threads.first.posts.first.url
exit

threads.each{ |th|
  post = th.posts.last
  puts "#{post.index}: #{post.body}"
  p post
  puts post.threa
}
