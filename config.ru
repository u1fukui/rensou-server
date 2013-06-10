# coding:utf-8
require 'active_record'
require 'mysql2'
require 'sinatra'
require './rensou.rb'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

class Rensou < ActiveRecord::Base
end

RensouApp.run!