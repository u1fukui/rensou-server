# coding:utf-8
require 'sinatra/base'

class RensouApp < Sinatra::Base

  before do
    logger = Logger.new("log/access.log", "daily")
    env['rack.logger'] = logger
  end

  post '/user' do
    reqData = JSON.parse(request.body.read.to_s)
    device_type = reqData['device_type']
    
    user = User.new
    user.device_type = device_type
    user.save()
    
    content_type :json, :charset => 'utf-8'
    {:user_id => user.id}.to_json
  end

  # 最新連想を取得
  get '/rensou.json' do
    content_type :json, :charset => 'utf-8'
    room = params['room']
    if room.nil? then
      room = getDefaultRoomType()
    end

    rensous = Rensou.where(room_type: room).last()
    rensous.to_json(:root => false)
  end

  get '/test' do
    raise "format error"
  end

  # 連想投稿
  post '/rensou.json' do
    # リクエスト解析
    reqData = JSON.parse(request.body.read.to_s)
    keyword = reqData['keyword']
    theme_id = reqData['theme_id']
    user_id = reqData['user_id']
    room = reqData['room']
    if user_id.nil? then
      user_id = 0
    end
    if room.nil? then
      room = getDefaultRoomType()
    end

    old_rensou = Rensou.find_by_id(theme_id)
    if old_rensou.nil? then
      status 400
    end

    # 保存データ作成
    rensou = Rensou.new
    rensou.keyword = keyword
    rensou.old_keyword = old_rensou.keyword
    rensou.id = theme_id + 1
    rensou.user_id = user_id
    rensou.favorite = 0
    rensou.spam = 0
    rensou.is_delete = false
    rensou.room_type = room

    begin

      # 保存
      rensou.save

      # レスポンスコード
      status 200

      # レスポンス生成
      content_type :json, :charset => 'utf-8'
      rensous = Rensou.order("id DESC").limit(50)
      rensous.to_json(:root => false)

    rescue ActiveRecord::RecordNotUnique => e

      # 更新されていた
      status 400

    end
  end

  # いいね！
  post '/rensous/:rensou_id/like' do
    # リクエスト解析
    rensou_id = params['rensou_id']
    
    # 追加 
    rensou = Rensou.find_by_id(rensou_id)
    rensou.update_attributes!(:favorite => rensou.favorite + 1)
    status 202
  end

  # いいね！を解除
  delete '/rensous/:rensou_id/like' do
    # リクエスト解析
    rensou_id = params['rensou_id']
   
    # 追加
    rensou = Rensou.find_by_id(rensou_id)
    rensou.update_attributes!(:favorite => rensou.favorite - 1)
    status 202
  end

  # 通報
  post '/rensous/:rensou_id/spam' do
    # リクエスト解析
    rensou_id = params['rensou_id']

    # 追加
    rensou = Rensou.find_by_id(rensou_id)
    rensou.update_attributes!(:spam => rensou.spam + 1)
    status 202
  end

  # ランキング取得
  get '/rensous/ranking' do
      room = params['room']
      if room.nil? then
        room = getDefaultRoomType()
      end

      # レスポンスコード
      status 200

      # レスポンス生成
      content_type :json, :charset => 'utf-8'
      rensous = Rensou.where(room_type: room).order("favorite DESC").limit(10)
      rensous.to_json(:root => false)
  end

  # 予期せぬエラー
  error do |e|
    status 500
    logger.error e
  end

  def getDefaultRoomType
    return 5	# 秘密の部屋
  end

end
