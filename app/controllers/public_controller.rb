class PublicController < ApplicationController
  def index
    @tags = Collection.find(:all,
                                    :select => 'name, count(tag_id) as tag_amount, t.id as id',
                                    :order => 'tag_amount desc',
                                    :group => 'tag_id',
                                    :limit => 60,
                                    :joins => 'as c inner join tags as t on c.tag_id=t.id')
    #@tags = @results.map {|t| t.name}
    @tag_counts = @tags.map {|t| t.tag_amount.to_i}    
  end
  
  def contribute_paper
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
      redirect_to :action => 'show_paper_detail', :id => @paper.id 
    
    else
      render :action => 'contribute_paper'
    end
  end

#use the show_paper_detail method in personal controller
  def show_paper_detail
    @paper =  Paper.find(params[:id])
    
    @tag_counts = Array.new
    @tags = @paper.tags
    for tag in @tags
      @tag_counts << tag.collections.count
    end
  end
  
  def list_tagged_paper
    @tag = Tag.find(params[:id])
    @papers = @tag.papers
    
    #如果性能有问题的话
    @related_tags = Array.new
    for other_tag in Tag.find_all
      if (@papers & other_tag.papers).empty? == false
        @related_tags << other_tag
      end
    end
    @related_tags = @related_tags.sort
  end

  def list_searched_paper
    #这里有可能要扩展
    @papers = getSearchResult(params[:query])
    
    @related_tags = Array.new
    for other_tag in Tag.find_all
      if (@papers & other_tag.papers).empty? == false
        @related_tags << other_tag
      end
    end
    @related_tags = @related_tags.sort
  end

  private
  def getSearchResult(query)
    Paper.find_by_contents(query)
    #render :text => 'hello'#Paper.find_id_by_contents(query)
  end

end
