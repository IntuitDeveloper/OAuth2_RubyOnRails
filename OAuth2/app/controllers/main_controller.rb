require 'yaml'

class MainController < ApplicationController
  def index
      config = YAML.load_file(Rails.root.join('config/config.yml'))
      params[:url] = config["Settings"]["oauth_start_uri"]
  end
end
