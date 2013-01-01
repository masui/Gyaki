# -*- coding: utf-8 -*-
# -*- ruby -*-

require 'rubygems'
require 'sinatra'
require 'base64'
require 'net/http'

get '/gyazodata/:id' do |id|
  res = Net::HTTP.start("gyazo.com",80){|http|
    http.get("/"+id+".png");
  }
  res.read_body
end

post '/upload' do
  id = params[:id]
  data = params[:data]

  data.sub!(/^.*base64,/,'')
  imagedata = Base64.decode64(data)

  boundary = '----BOUNDARYBOUNDARY----'
  gyazo_host = 'gyazo.com'
  gyazo_cgi = '/upload.cgi'
  gyazo_ua   = 'Gyazo/1.0'
  data = <<EOF
--#{boundary}\r
content-disposition: form-data; name="id"\r
\r
#{id}\r
--#{boundary}\r
content-disposition: form-data; name="imagedata"; filename="gyazo.com"\r
\r
#{imagedata}\r
--#{boundary}--\r
EOF
  header ={
    'Content-Length' => data.length.to_s,
    'Content-type' => "multipart/form-data; boundary=#{boundary}",
    'User-Agent' => gyazo_ua
  }
  res = Net::HTTP.start(gyazo_host,80){|http|
    http.post(gyazo_cgi,data,header)
  }
  res.read_body
end

get '/:id1/:id2' do |gyazoUserID,gyazoImageID|
  @gyazoUserID = gyazoUserID
  @gyazoImageID = gyazoImageID
  erb :draw
end

get '/:id' do |gyazoUserID|
  @gyazoImageID = nil
  @gyazoUserID = gyazoUserID
  erb :draw
end
