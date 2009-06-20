# -*- coding: utf-8 -*-
require 'sequel'
require 'cgi'
Sequel::Model.plugin(:schema)
DB = Sequel.sqlite('hot_keyword.db')

class HotKeyword < Sequel::Model
  TOP_URI = 'http://h.hatena.ne.jp/'
  SOURCE_URI = 'http://h.hatena.ne.jp/hotkeywords'

  set_schema do
    primary_key :id
    String :keyword, :null => false
    Integer :level, :null => false
    time :created
  end
  create_table unless table_exists?

  def uri
    TOP_URI + 'keyword/' + CGI.escape(self.keyword)
  end

  # TODO: fetch method with level
end
