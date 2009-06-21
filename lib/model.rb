require 'open-uri'
require 'hpricot'
require 'twitter'
require 'kconv'
require 'pit'
require 'cgi'

class Api
  def initialize(name)
    config = Pit.get(name, :require => {
        'username' => 'you email in twitter',
        'password' => 'your password in twitter',
      })
    httpAuth = Twitter::HTTPAuth.new(config['username'], config['password'])
    @twitter = Twitter::Base.new(httpAuth)
  end

  def update(string)
    puts "update: " + string
    @twitter.update string.toutf8
  end
end

class HotKeyword < Hash
  TOP_URI = 'http://h.hatena.ne.jp/'
  SOURCE_URI = 'http://h.hatena.ne.jp/hotkeywords'
  attr_accessor :level, :keyword

  def level
    self[:level]
  end
  def keyword
    self[:keyword]
  end

  def uri
    TOP_URI + 'keyword/' + CGI.escape(self.keyword)
  end

  def self.fetch
    doc = Hpricot(open(SOURCE_URI).read)
    doc.search('div.streambody > ul.cloud > li').map do |item|
      level = item.get_attribute('class').scan(/\d+$/).to_s.to_i
      anchor = item.search('a.keyword').first
      keyword = anchor.inner_text
      self[:level =>  level, :keyword => keyword]
    end
  end
end
