# coding:utf-8
require 'active_record'
require 'mysql2'
require 'sinatra'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

class Topic < ActiveRecord::Base
end

# 最新トピックを取得
get '/latest' do
  content_type :json, :charset => 'utf-8'
  topic = Topic.last
  topic.to_json
end

# トピック投稿
post '/topic' do
  # リクエスト解析
  reqData = JSON.parse(request.body.read.to_s) 
  title = reqData['title']
  description = reqData['description']
  
  # 保存データ作成
  topic = Topic.new
  topic.title = title
  topic.description = description

  # 保存
  topic.save
    
  # レスポンス生成
  topics = Topic.order("created_at DESC").limit(10)
  topics.to_json(:root => false)
  status 202  

endd
