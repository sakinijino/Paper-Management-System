class PublicController < ApplicationController
  layout 'frame'
  include AuthenticatedSystem  
  
  def index
    @tags = Collection.find(:all,
                                    :select => 'name, count(tag_id) as tag_amount, t.id as id',
                                    :order => 'tag_amount desc',
                                    :group => 'tag_id',
                                    :limit => 60,
                                    :joins => 'as c inner join tags as t on c.tag_id=t.id').sort_by{|item| item.id}
    @tag_counts = @tags.map {|t| t.tag_amount.to_i} 
    
    @popular_papers = Paper.find_by_sql(
                                                      "SELECT p.id, p.title
                                  FROM (SELECT * FROM collections group by paper_id,user_id) 
                                  as c inner join papers p on p.id=c.paper_id group by c.paper_id order by count(c.user_id) desc
                                  ")
                                    
    @newest_papers = Paper.find(:all,
                                             :order => 'id desc',
                                             :limit => 10)                         
  end
  
  def contribute_paper
    render :layout=>"frame_no_search"
  end
  
  def create_paper
    @paper = Paper.new(params[:paper])
    
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
    @papers = @tag.papers.find(:all,:page => {:size=>10,:current=>params[:page]})    
  end

  def list_searched_paper
    #这里有可能要扩展
    @papers = getSearchResult(params[:query])
    
    @related_tags = Array.new
    @related_tags_counts = []
    for other_tag in Tag.find_all
      if (@papers & other_tag.papers).empty? == false
        @related_tags << other_tag
        @related_tags_counts << other_tag.collections.count
      end
    end
    #@related_tags = @related_tags.sort
  end

  private
  def getSearchResult(query)
    Paper.find_by_contents(query)
    #render :text => 'hello'#Paper.find_id_by_contents(query)
  end

end
