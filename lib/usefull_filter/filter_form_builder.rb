module UsefullFilter
  class FilterFormBuilder < ActionView::Helpers::FormBuilder
    
    DEFAULT_TYPES=["equals", "does_not_equal", "in", "not_in"]
    STRING_TYPES=["contains", "does_not_contain", "starts_with", "does_not_start_with", "ends_with", "does_not_end_with"]
    NUMBER_TYPES=["greater_than", "greater_than_or_equal_to", "less_than", "less_than_or_equal_to"]
    BOOLEAN_TYPES=["is_true", "is_false"]
    OTHER_TYPES=["is_present", "is_blank"]
  
    #Ridefinisco il metodo per wrapparlo all'interno di una lista
    #Accetta i seguenti parametri:
    #*  :default_filter => "equals"
    #*  :filters => ["equals", ....]
    #
    #Il nome sarà del tipo
    #*  :ART
    #*  "document.activity.id" (come per la tabelle)
    def text_field(object_name, *args)
        opt = define_args(args, object_name)
        name = object_name.to_s.gsub(/\./, "_")
        opt.merge!(@options[:html_1][:input])
        #UserSession.log("FilterHelper#text_field:opt=#{opt.inspect}")
        @template.content_tag(:li) do
          @template.concat filter_list(name, opt[:default_filter], opt)
          @template.concat " "
          @template.concat super(default(name, opt[:default_filter]), opt)
          ##UserSession.log("FilterHelper#text_field:object_name=#{object_name.inspect}")
          #@template.concat attribute_type(object_name) == :Date ? @template.link_to(@template.image_tag('calendar16.png'), '#', :onclick => "show_calendar('search_data_prevista_equals')") : ''
        end
    end
    
    #Utilizza come filtro una combo, con i valori passati nell'array
    def select(object_name, array, *args)
      opt = define_args(args, object_name)
      name = object_name.to_s.gsub(/\./, "_")
      opt.merge!(@options[:html_1][:input])
      @template.content_tag(:li) do
        @template.concat filter_list(name, opt[:default_filter], opt)
        @template.concat " "
        #@template.concat select("search", default(name, opt[:default_filter]), array.collect {|p| [p,p]}, opt)
        @template.concat super(default(name, opt[:default_filter]), array, opt)
        ##UserSession.log("FilterHelper#text_field:object_name=#{object_name.inspect}")
      end
    end
    
    #Utilizza come filtro un elenco di valori rappresentati da una check_box
    #che vengono gestiti come OR
    #def checks(object_name, array, *args, &block)
    #  super.to_s.html_safe
    #end
    
    
    #Genera una doppia text_box per gestire i filtri tra due
    def between_field(object_name, *args)
      opt = define_args(args, object_name)
      name = object_name.to_s.gsub(/\./, "_")
      @template.content_tag(:li,
        multiparameter_field(name.to_s + "_between", 
          {:field_type => :text_field}, {:field_type => :text_field}, :size => 5))
    end
    
    def submit
    	applay_filter_label = I18n.t(:applay_filter, :scope => "metasearch.buttons")
      super(applay_filter_label, :class => "push-1")
    end
      
    private
    
    #Aggiusta il vettore dei parametri passati
    #*  :default_filter => "equals"  filtro di default che deve essere presente in tutti i metodi
    #*  :filters_only => ["equals", .. ] elenco di filtri da utilizzare, rimpiazza anche i dafault
    #*  :filters_except => ["equals", .. ] elenco di filtri da escludere
    #*  :filters => [..] elenco dei filtri richiesti, sovrascrive i default
    #*  :filters_type => :string | :number | :boolean | :other da aggiungere a quelli gia presenti
    def define_args(args, object_name)
      opt = args.extract_options!
      #Il filtro di default e _equals che deve essere presente su tutti i campi
      opt[:filters] ||= DEFAULT_TYPES + type(object_name)
      opt[:default_filter] ||= opt[:filters].include?("equals") ? "equals" : opt[:filters].first
      opt[:filters_only] ||= []
      opt[:filters_except] ||= []
      case opt[:filters_type]
        when :string
          opt[:filters] |= STRING_TYPES
        when :number
          opt[:filters] |= NUMBER_TYPES
        when :boolean
          opt[:filters] |= BOOLEAN_TYPES
        when :other
          opt[:filters] |= OTHER_TYPES
        end
        
      opt[:filters] -= opt[:filters_except]
      opt[:filters] = opt[:filters_only] unless opt[:filters_only] .blank?
      opt
    end
    
    #Costruisce l'elenco dei filtri da utilizzare
    #seleziona come selected il parametro trovato in params[] per garantire coerenza dopo il reload
    def options_list(object_name, args, default_filter="equals")
      filters = args[:filters].dup
      filters.map! {|o| 
        "<option value = '" + object_name.to_s + "_" +  o + "'" +
        (default(object_name,default_filter) == object_name.to_s + "_" + o ? " selected = 'selected'" : "") +
        " >" +
        I18n.t(o, :scope =>"meta_search.predicates", :attribute => human(object_name)) +
        "</option>"}
      filters.join("").html_safe
    end
    
    #Crea una lista dei filtri disponibili per il campo
    def filter_list(object_name, default_filter, args)
      list = options_list(object_name, args,default_filter)
      ##UserSession.log("FilterHelper#filter_list:options=#{@options.inspect}")
      #UserSession.log("FilterFormBuilder#filter_list list=#{list}")
      #@template.select_tag(object_name, list.html_safe, :onchange => "document.getElementById('search_' + #{object_name.to_s}).name = 'search[' + this + ']'")
      @options[:html_1][:select][:onchange] = "$(#{'search_' + default(object_name,default_filter)}).name = 'search[' + this.value + ']'; $(#{'search_' + default(object_name, default_filter)}).id = 'search_' + this.value "
      @options[:html_1][:select][:id]       = object_name.to_s
      @options[:html_1][:select][:class]    = "select_dati"
      ##UserSession.log("FilterHelper#filter_list:options(before select_tag)=#{@options.inspect}")
      @template.select_tag("", list, @options[:html_1][:select])
    end
    
    #Restituisce l'elenco dei filtri associati al tipo di dati del DB
    def type(object_name)
      #case @object.base.columns_hash[object_name.to_s].type
      case attribute_type(object_name)
        when :String  then
          STRING_TYPES
        when :Bignum, :Fixnum, :Float, :Date, :Time, :Datetime then
          NUMBER_TYPES
        when :TrueClass, :FalseClass then
          BOOLEAN_TYPES
        when nil
          []
        else
          OTHER_TYPES
      end
    end
    
    #Restituisce il tipo dellìattributo
    #gestendo i multilivello document.activity.data_prevista => :Date
    #==Nota:
    #*  non testata con le relazioni polimorfiche...
    #*  con metodi definit all'utente, restiuisce nil 
    def attribute_type(attribute_name)
      #UserSession.log("FilterFormBuilder#attribute_type attribute_name=#{attribute_name}, base=#{@object.base.name}")
      #Aggiungo self. daventi in quanto i campi tipo ART vengono confusi per costanti se non specifico il contesto. SIGH!

      attributes = attribute_name.to_s.split(".")
      base = @object.base
      method = attributes.pop
      #UserSession.log("FilterFormBuilder#attribute_type(1) method=#{method}, base=#{base.name}, attributes=#{attributes.inspect}")
      if attributes.length > 0
        attributes.each do |association|
          reflection = base.reflect_on_association(association.to_sym)
          base = reflection.blank? ? nil : reflection.klass
        end
      end
      ##UserSession.log("FilterFormBuilder#attribute_type(2) method=#{method}")
      base.columns_hash[method.to_s].klass.name.to_sym unless base.blank? || base.columns_hash[method.to_s].blank?
    end
    
    #Restituisce il nome del campo preso da ActiveRecord
    def human(object_name)
      ##UserSession.log("FilterFormBuilder#human classe=#{@object.class.name}")
      @object.base.human_attribute_name(object_name.to_s)
    end
    
    #Restituisce il valore di default prelevato da params[]
    #altrimenti restituisce nome_equals
    def default(nome, filter="equals")
      out = ""
      @object.search_attributes.each_key do |k|
        out = k unless k.match(/^#{nome.to_s}/).nil?
      end
      out = out.blank? ? nome.to_s + "_" + filter : out
      out
    end
    
  end
 
end
