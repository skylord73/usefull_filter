require 'rails/generators'
module UsefullFilter
  class InstallGenerator < Rails::Generators::Base
    desc "Install generator for UsefullFilter gem"
    source_root File.expand_path("../templates", __FILE__)
    
    #def copy_config
    #  directory "config"
    #end
    
    #def copy_public
    #  directory "public"
    #end
    
  end      
end

