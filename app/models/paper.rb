class Paper < ActiveRecord::Base
  has_many :collections
  has_many :users, :through => :collections, :select => "distinct users.*"
  has_many :tags, :through => :collections, :select => "distinct tags.*"
  has_many :notes
  has_and_belongs_to_many :authors
  
  file_column :attachment
  acts_as_ferret :fields => {
                                        :title => {},
                                        :abstract => {},
                                        :identifier => {},
                                        :author_list => {},
                                        :tag_list => {}, 
                                        :source => {},
                                        :publish_time_f => {:index => :untokenized}
                                      },
                      :analyzer => 'Ferret::Analysis::StandardAnalyzer'
  
  def author_list
    (self.authors.map {|a| a.name}).join(" ")
  end
  
  def author_list_with_comma
    (self.authors.map {|a| a.name}).join(", ")
  end
  
  def tag_list
    (self.tags.map {|a| a.name}).join(" ")
  end
  
  def publish_time_f
    self.publish_time.strftime("%Y%m")
  end
  
  def self.full_text_search(q, options = {})
     return nil if q.nil? or q==""
     default_options = {:limit => 10, :page => 1}
     options = default_options.merge options
     
     options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  
     
     results = Paper.find_by_contents(q, options)
     return [results.total_hits, results]
   end
   
  def self.clone_from_checked_paper(a_checked_paper)
    a_created_paper = Paper.new(
                                              'title'=>a_checked_paper.title,
                                              'abstract'=>a_checked_paper.abstract,
                                              'publish_time'=>a_checked_paper.publish_time,
                                              'identifier'=>a_checked_paper.identifier,
                                              'source'=>a_checked_paper.source
                                              );
    if a_checked_paper.attachment != nil
      a_created_paper.attachment = File.open(a_checked_paper.attachment)
      FileUtils.cp(a_created_paper.attachment, a_checked_paper.attachment)
      FileUtils.remove_file(a_checked_paper.attachment, force = true)
    end
    
    a_created_paper.save
                              
    if a_created_paper != nil
      a_created_paper.authors = a_checked_paper.authors
      CheckingPaper.destroy(a_checked_paper)
    end
  end
end
