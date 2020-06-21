
require 'rails/generators/base'

module Editmode
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def install
        copy_initializer
      end

      private
      def copy_initializer
        template "editmode.rb", "config/initializers/editmode.rb"
      end
    end
  end
end