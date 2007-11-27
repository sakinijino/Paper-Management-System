class Paper < ActiveRecord::Base
  has_many :users, :through => :collections, :select => "distinct users.*"
  has_many :tags, :through => :collections, :select => "distinct tags.*"
  has_many :notes, :dependent => :destroy
  has_many :collections, :dependent => :destroy
  
  has_and_belongs_to_many :authors
  
  validates_uniqueness_of   :identifier, :allow_nil=>true
  validates_presence_of :title
  validates_length_of       :title,    :within => 0..1000
  validates_length_of       :source,    :within => 0..1000
  
  file_column :attachment

  #~ GENERIC_ANALYSIS_REGEX = /([a-zA-Z]|[\xc0-\xdf][\x80-\xbf])+|[0-9]+|[\xe0-\xef][\x80-\xbf][\x80-\xbf]/
  #~ GENERIC_ANALYZER = Ferret::Analysis::RegExpAnalyzer.new(GENERIC_ANALYSIS_REGEX, true)
  GENERIC_ANALYZER = MultilingualFerretTools::Analyzer.new
  #~ GENERIC_ANALYZER = Ferret::Analysis::StandardAnalyzer.new
  acts_as_ferret ({:fields => [
                                        :title,
                                        :abstract,
                                        :identifier,
                                        :author_list,
                                        :tag_list, 
                                        :source,
                                        :publish_time_f
                                      ]},
               { :analyzer => GENERIC_ANALYZER })
#~ Ferret::Analysis::RegExpAnalyzer.new(/./,false) })
#~ MultilingualFerretTools::Analyzer.new })               

  
  def author_list
    (self.authors.map {|a| a.name}).join(" ")
  end
  
  def author_list_with_comma
    (self.authors.map {|a| a.name}).join(", ")
  end  
  
  def tag_list
    (self.tags.map {|a| a.name}).join(" ")
  end
  
  def popular_tags(limit=5)
    tags = Collection.find(:all,
                                    :select => 'name, count(tag_id) as tag_amount, t.id as id, c.paper_id as paper_id',
                                    :order => 'tag_amount desc',
                                    :group => 'tag_id',
                                    :limit => limit,
                                    :joins => 'as c inner join tags as t on c.tag_id=t.id',
                                    :conditions => ["paper_id=:p_id",{:p_id=>self.id}])
  end
  
  def publish_time_f
    self.publish_time.strftime("%Y.%m")
  end
  
  def self.full_text_search(q, options = {})
     return nil if q.nil? or q==""
     default_options = {:limit => 10, :page => 1}
     options = default_options.merge options
     
     options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  
     
     results = Paper.find_by_contents(q, options)
     return [results.total_hits, results]
  end  
  
end
