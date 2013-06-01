# coding:utf-8
require 'active_record'
require 'mysql2'
require 'sinatra'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

class Rensou < ActiveRecord::Base
end

# 最新連想を取得
get '/rensous.json' do
  content_type :json, :charset => 'utf-8'

  rensous = Rensou.order("created_at DESC").limit(20)
  rensous.to_json(:root => false)
end

# 連想投稿
post '/rensou.json' do
  # リクエスト解析
  reqData = JSON.parse(request.body.read.to_s) 
  keyword = reqData['keyword']
  theme_id = reqData['theme_id']
    
  p theme_id

  # 保存データ作成
  rensou = Rensou.new
  rensou.keyword = keyword
  rensou.id = theme_id + 1
  rensou.favorite = 0
  rensou.spam = 0
  rensou.is_delete = false

  p rensou.id

  begin

    # 保存
    rensou.save
    
    # レスポンス生成
    rensous = Rensou.order("created_at DESC").limit(20)
    rensous.to_json(:root => false)

    status 202  

  rescue ActiveRecord::RecordNotUnique => e
  
    # 更新されていた
    puts e
    status 400
  
  end
end

# 予期せぬエラー
error do
  status 500
  #TODO: ログに出す
  'エラーが発生しました。 - ' + env['sinatra.error'].name
end
