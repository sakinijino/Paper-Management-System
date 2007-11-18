class PersonalController < ApplicationController
  layout 'frame'
  include AuthenticatedSystem
  
  def add_personal_info
    #当推荐其他相关标签时有用
  end
  
  def add_to_collection
    paper = Paper.find(params[:id])

    if current_user.papers.find_by_id(paper.id)
      flash[:notice] = 'You have already added this paper.'
      redirect_to :action => 'show_paper_detail', :id => paper.id
    else
      for tag_name in params[:paper][:tags].split.uniq
        collection = Collection.new
        collection.paper = paper
        collection.user = current_user
        tag = Tag.find_by_name(tag_name)
        if tag == nil
          tag = Tag.create({:name => tag_name})
        end
        collection.tag = tag
        collection.status = params[:paper][:status]
        collection.save
      end
    redirect_to :action=>'list_collection',:id=>current_user.id
    end
  end
  
  def list_collection
    @user = User.find(params[:id])
    
    show_num = 5
    @to_read_papers = Paper.find(:all,
                                    :select => 'p.id as id, p.title as title',
                                    :conditions => ["c.status=:status and c.user_id=:uid",{:status=>'To Read',:uid=>@user.id}],
                                    :order => 'c.id desc',
                                    :group => 'p.id',
                                    :joins => 'as p inner join collections as c on p.id=c.paper_id')
    if(@to_read_papers.size > show_num)
      @to_read_papers = @to_read_papers[0,show_num]
      @to_read_show_more = true
    else
      @to_read_show_more = false
    end

    @reading_papers = Paper.find(:all,
                                    :select => 'p.id as id, p.title as title',
                                    :conditions => ["c.status=:status and c.user_id=:uid",{:status=>'Reading',:uid=>@user.id}],
                                    :order => 'c.id desc',
                                    :group => 'p.id',
                                    :joins => 'as p inner join collections as c on p.id=c.paper_id')
    if(@reading_papers.size > show_num)
      @reading_papers = @reading_papers[0,show_num]
      @reading_show_more = true
    else
      @reading_show_more = false
    end
    
    @finished_papers = Paper.find(:all,
                                    :select => 'p.id as id, p.title as title',
                                    :conditions => ["c.status=:status and c.user_id=:uid",{:status=>'Finished',:uid=>@user.id}],
                                    :order => 'c.id desc',
                                    :group => 'p.id',
                                    :joins => 'as p inner join collections as c on p.id=c.paper_id')
    if(@finished_papers.size > show_num)
      @finished_papers = @finished_papers[0,show_num]
      @finished_show_more = true
    else
      @finished_show_more = false
    end
    
    @my_tag_counts = Array.new
    @my_tags = @user.tags
    for tag in @my_tags
      @my_tag_counts << Collection.find_all_by_user_id_and_tag_id(@user.id, tag.id).size   
    end
    
    @my_notes = Note.find_all_by_user_id(@user.id)
  end
  
  def list_all_paper
    @status = params[:status]
    @all_papers = Paper.find(:all,
                                  :select => 'paper_id as id, title',
                                  :conditions => ["c.status=:status",{:status=>@status}],
                                  :order => 'c.id desc',
                                  :group => 'paper_id',
                                  :joins => 'inner join collections as c on papers.id=c.paper_id',
                                  :page => {:size=>10,:current=>params[:page]})   
  end
  
  def show_paper_detail
    @paper = Paper.find(params[:id])
    @tags = Collection.find(:all,
                                     :conditions => ["user_id=:uid and paper_id=:pid",{:uid=>current_user.id, :pid=>@paper.id}],
                                    :select => 't.name,t.id, c.paper_id, c.user_id',
                                    :joins => 'as c inner join tags as t on c.tag_id=t.id')
    if @tags.empty?
      @un_collected = true
    end
    
    @public_notes = Note.find_all_by_paper_id_and_is_private(@paper.id, 'false')
    @personal_notes = Note.find_all_by_paper_id_and_user_id(@paper.id, current_user.id)
  end

  def new_note
    @paper = Paper.find(params[:id])
  end

  def create_note
    note = Note.new(params[:note])
    note.user_id = current_user.id
    note.paper_id = params[:id]
    note.publish_time = Time.now
    
    if note.save
      flash[:notice] = 'Note has been successfully created.'
      redirect_to :action => 'show_paper_detail', :id => note.paper_id
    else
      render :action => 'new_note'
    end      
  end
  
  def edit_note
    @note = Note.find(params[:id])
  end
  
  def update_note
    @note = Note.find(params[:id])
    if @note.update_attributes(params[:note])
      flash[:notice] = 'Note has been successfully updated.'
      redirect_to :action => 'show_paper_detail', :id => @note.paper_id
    else
      render :action => 'edit_note'
    end
  end
end
