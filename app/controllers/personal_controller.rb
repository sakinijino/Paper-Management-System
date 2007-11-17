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
    redirect_to :action=>'list_my_paper',:id=>current_user.id
    end
  end
  
  def list_collection
    @user = User.find(params[:id])
    @to_read_papers = Array.new
    @reading_papers = Array.new
    @finished_papers = Array.new
    
    for paper in @user.papers
      if Collection.find_by_user_id_and_paper_id(@user.id,paper.id).status == 'To Read'
        @to_read_papers << paper
      elsif paper.collections.find_by_user_id(@user.id).status == 'Reading'
        @reading_papers << paper
      else
        @finished_papers << paper
      end
    end
    
    @my_tag_counts = Array.new
    @my_tags = @user.tags
    for tag in @my_tags
      @my_tag_counts << tag.collections.count    
    end
    
    @my_notes = Note.find_all_by_user_id(@user.id)
  end  
  
  def show_paper_detail
    @paper = Paper.find(params[:id])
    @tags = Collection.find(:all,
                                     :conditions => ["user_id=:uid and paper_id=:pid",{:uid=>current_user.id, :pid=>@paper.id}],
                                    :select => 't.name,t.id, c.paper_id, c.user_id',
                                    :joins => 'as c inner join tags as t on c.tag_id=t.id')
    if @tags.empty?
      @un_collected = true
      return;
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
