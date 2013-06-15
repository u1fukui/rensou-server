# coding:utf-8
require 'active_record'
require 'mysql2'
require 'sinatra'
require './rensou.rb'

enable :logging, :dump_errors

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

class Rensou < ActiveRecord::Base
end

run RensouApp