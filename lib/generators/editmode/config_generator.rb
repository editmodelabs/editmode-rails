
require 'rails/generators/base'

module Editmode
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      argument :project_id, :desc => "Your Editmode project_id, which can be found here: https://www.editmode.com/projects"

      def create_config_file
        @project_id = project_id
        
        introduction = <<-intro
Editmode will automatically insert its javascript before the closing '</body>'
tag on every page.

        intro

        print "#{introduction} "

        template "editmode.rb.erb", "config/initializers/editmode.rb"
      end
    end
  end
end