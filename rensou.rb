# coding:utf-8
require 'sinatra/base'

class RensouApp < Sinatra::Base
  # 最新連想を取得
  get '/rensou.json' do
    content_type :json, :charset => 'utf-8'

    rensous = Rensou.last()
    rensous.to_json(:root => false)
  end

  # 連想投稿
  post '/rensou.json' do
    # リクエスト解析
    reqData = JSON.parse(request.body.read.to_s)
    keyword = reqData['keyword']
    theme_id = reqData['theme_id']

    # 保存データ作成
    rensou = Rensou.new
    rensou.keyword = keyword
    rensou.id = theme_id + 1
    rensou.favorite = 0
    rensou.spam = 0
    rensou.is_delete = false

    begin

      # 保存
      rensou.save

      # レスポンスコード
      status 200

      # レスポンス生成
      content_type :json, :charset => 'utf-8'
      rensous = Rensou.order("created_at DESC").limit(20)
      rensous.to_json(:root => false)

    rescue ActiveRecord::RecordNotUnique => e

      # 更新されていた
      status 400

    end
  end

  # 予期せぬエラー
  error do
    status 500
    #TODO: ログに出す
    'エラーが発生しました。 - ' + env['sinatra.error'].name
  end

end