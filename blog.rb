#!/usr/bin/env ruby

require 'commander/import'
program :name, 'YABA (Yet Another Blog Application)'
program :version, '1.0'
program :description, 'The cli version of YABA'

require 'bundler'
Bundler.require(:default, :development)

require 'pry'
if ENV['YABA_DB'] == 'mongoid'
  require 'mongoid'
  Mongoid.load!("config/mongoid.yml", :development)
else
  require 'active_record'
  connection_info = YAML.load_file("config/database.yml")["development"]
  ActiveRecord::Base.establish_connection(connection_info)
end

require 'yaba/core'
Yaba::Core::Config.configure do |config|
  config.repository = :active_record
  if ENV['YABA_DB'] == 'mongoid'
    config.repository.posts = :mongoid
  end
end

command :get do |c|
  c.action do |args, options|
    entity = args[0]
    id = args[1]
    if entity == 'post'
      post = Interactors::GetsPosts.new.get(post_id: id)
      puts "Post number #{post.id}"
      puts post.body
    end
  end
end

command :create do |c|
  c.action do |args, options|
    entity = args.shift
    if entity == 'post'
      Interactors::CreatesPosts.new(post_params: Hash[*args]).create
    end
  end
end
