# coding:utf-8
require 'active_record'
require 'mysql2'
require 'sinatra'
require './rensou.rb'

disable :logging, :dump_errors

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('production')

class Rensou < ActiveRecord::Base
end

class User < ActiveRecord::Base
end

run RensouApp
