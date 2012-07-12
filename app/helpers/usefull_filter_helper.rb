#require "usefull_filter/filter_form_builder"
#L'helper si occupa di wrappare la classe MetaSearch permettendo l'utilizzo di Filtri selezionabili dall'utente
#
#[documents_controller]
# Vedi TableHelper
#
#[index.html.erb]
# <%=filter_for_new @search, :url => magazzino_documents_path do |f| %>
#   <%= f.text_field :data, :size => 10, :filters => ["equals", "less_than_or_equal_to", "greater_than_or_equal_to"] %>
#   <%= f.text_field :DoCNr, :filters_type => :number %>
#   <%= f.text_field :TbDoC, :filters_only => ["equals"] %>
#   <%= f.text_field :BollaXENrDoC, filters_except => ["equals", "does_not_equal"] %>
#   <%= f.text_field :DoCSit %>
#   <%= f.submit %>
# <% end %>
module UsefullFilterHelper
  #Contatta l'url passato ripassando i filtri attivi in @search
  def filter_button_tag(name, url, method = :get)
    if @search.kind_of?(MetaSearch::Builder)
      form_tag(url, :method => method) do
        @search.search_attributes.each  do |k,v|
          if v.kind_of?(Array)
            v.each{|vv| concat hidden_field_tag("search[#{k}][]", vv)} 
          else
            concat hidden_field_tag("search[#{k}]", v)
          end
        end
        concat submit_tag(name)
      end
    end
  end
  
  def filter_for_new(obj, *args, &proc)
    filter_for(obj, *args, &proc)
  end
  
  #Cerca una serie di filtri utilizzando MetaSearch di cui fa il wrapper
  #obj è una istanza metashearch
  def filter_for(obj, *args, &proc)
    unless obj.blank?
      options = args.extract_options!

      options[:html] ||= {}
      #options[:html][:select] ||= { :style => "margin:0 0 0 0;"}
      #options[:html][:input] ||= { :style => "margin:0 0 0 0;"}
      options[:html][:select] ||= {}
      options[:html][:input] ||= {}
      options[:html][:method] ||= :get
      options[:html][:class] ||= "span-24 filter_bar"
      options[:html_1] = options.delete(:html)
      options.merge!(:builder => UsefullFilter::FilterFormBuilder)
     
      remove_filter_label = I18n.t(:remove_filter, :scope => "metasearch.buttons")
      filter_title = I18n.t(:filter_title, :scope => "metasearch.buttons")
      
      #Estraggo le options che mi interessano, perchè una volta passate al builder
      #per qulache arcano motivo vengono alterate....
      classe = options[:html_1].delete(:class)
      url = options[:url]
      #UserSession.log("FilterHelper#filter_for_new: options=#{options.inspect}")
      content_tag(:div,
        content_tag(:h3, filter_title) +
        content_tag(:ul,
          form_for(obj, *(args << options), &proc) +
          form_tag(url_for(url), :method => :get) do
            obj.search_attributes.each_key {|k| concat hidden_field_tag("search[#{k}]") } 
            concat submit_tag(remove_filter, :class => "push-2")
          end ),
      :class => classe)
    end
  end

end

