require 'twitter'
require 'kconv'
require 'pit'

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
