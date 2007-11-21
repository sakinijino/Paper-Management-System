class PublicController < ApplicationController
  layout 'frame'
  include AuthenticatedSystem
  before_filter :login_required  
  
  def index
    @tags = Collection.find(:all,
                                    :select => 'name, count(tag_id) as tag_amount, t.id as id',
                                    :order => 'tag_amount desc',
                                    :group => 'tag_id',
                                    :limit => 60,
                                    :joins => 'as c inner join tags as t on c.tag_id=t.id').sort_by{|item| item.id}
    @tag_counts = @tags.map {|t| t.tag_amount.to_i} 
    
    @popular_papers_id = Paper.find_by_sql(
                                                      "SELECT p.id
                                  FROM (SELECT * FROM collections group by paper_id,user_id) 
                                  as c inner join papers p on p.id=c.paper_id group by c.paper_id
                                  order by count(c.user_id) desc limit 5
                                  ")
    @popular_papers = []
    for p in @popular_papers_id
      @popular_papers << Paper.find(p.id)
    end
                                    
    @newest_papers = Paper.find(:all,
                                             :order => 'id desc',
                                             :limit => 5)                         
  end
  
  def contribute_paper
    @authors = []
    render :layout=>"frame_no_search"
  end
  
  def create_paper
    @paper = Paper.new(params[:paper])
    @authors = params[:author_name]
    
    if @paper.save
      for name in params[:author_name].uniq
        new_author = Author.find_by_name(name)
        if new_author == nil
          new_author = Author.create({:name=>name})
        end

        if @paper.authors.find_by_name(new_author.name) == nil
          @paper.authors << new_author
        end
      end      
      flash[:notice] = 'Paper has been successfully uploaded.'
      redirect_to :controller=>'personal', :action => 'show_paper_detail', :id => @paper.id 
    
    else
      render :action => 'contribute_paper'
    end
  end
  
  def list_tagged_paper
    @tag = Tag.find(params[:id])
    #~ @related_tags = Tag.find(:all,
                                    #~ :select => 't.id, t.name, count',
                                    #~ :conditions => ["c.=:status and c.user_id=:uid",{:status=>'Reading',:uid=>@tag.id}],
                                    #~ :order => 'c.id desc',
                                    #~ :group => 'p.id',
                                    #~ :joins => 'as t inner join collections as c on t.id=c.tag_id')
    #~ @related_tags_counts << @related_tags.map {|x| x.count_num}
    #~ @papers = @tag.papers.find(:all, :page => {:size=>10,:current=>params[:page]})    
    
    @papers = @tag.papers    
    #这里需要用join重写，如果性能有问题的话
    @related_tags = Array.new
    @related_tags_counts = []
    for other_tag in Tag.find_all - [@tag]
      if (@papers & other_tag.papers).empty? == false
        @related_tags << other_tag
        @related_tags_counts << other_tag.collections.count
      end
    end
    if params[:sort] == 'date'
      @papers = @tag.papers.find(:all,
                                            :order => 'publish_time desc',
                                            :page => {:size=>10,:current=>params[:page]})
    else
      @papers = Paper.find(:all,
                                    :select => 'papers.*, count(paper_id) as tagged_count',
                                    :conditions => ["c.tag_id=:tag_id",{:tag_id=>@tag.id}],
                                    :order => 'tagged_count desc',
                                    :group => 'paper_id',
                                    :joins => 'inner join collections as c on c.paper_id=papers.id',                                    
                                    :page => {:size=>10,:current=>params[:page]})
    end
  end

  def list_searched_paper
    @query = params[:query]
    
    if params[:sort] == 'date'
      s = Ferret::Search::SortField.new(:publish_time_f, :reverse => true)        
      @total, @papers = Paper.full_text_search(params[:query], {:page => (params[:page]||1),:sort => s})
    else
      @total, @papers = Paper.full_text_search(params[:query], :page => (params[:page]||1))
    end    
    @pages = pages_for(@total)    
    
    @related_tags = Array.new
    @related_tags_counts = []
    for other_tag in Tag.find_all
      if (@papers & other_tag.papers).empty? == false
        @related_tags << other_tag
        @related_tags_counts << other_tag.collections.count
      end
    end
  end


end
