module UsefullFilter
  class Engine < Rails::Engine
    
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    initializer 'usefull_filter.helper' do |app|
      ActiveSupport.on_load(:action_controller) do
        include UsefullFilterHelper
      end
      ActiveSupport.on_load(:action_view) do
        include UsefullFilterHelper
      end
     
    end
  end
  
end

#Add ere require to specific file or gem used
