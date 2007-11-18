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
    
    @my_notes = Note.find(:all,
                                    :conditions => ["user_id=:uid",{:uid=>@user.id}],
                                    :order => 'id desc'
                                    )
    if @user.id != current_user.id
      @my_notes = @my_notes.find_all {|x| x.is_private == false}
    end
    if(@my_notes.size > show_num)
      @my_notes = @my_notes[0,show_num]
      @my_notes_show_more = true
    else
      @my_notes_show_more = false
    end                                  
  end
  
  def list_all_paper
    @status = params[:status]
    @user = User.find(params[:id])
    @all_papers = Paper.find(:all,
                                  :select => 'paper_id as id, title',
                                  :conditions => ["c.user_id=:uid and c.status=:status",{:uid=>@user.id, :status=>@status}],
                                  :order => 'c.id desc',
                                  :group => 'paper_id',
                                  :joins => 'inner join collections as c on papers.id=c.paper_id',
                                  :page => {:size=>10,:current=>params[:page]})   
  end

  def list_all_my_note
    @user = User.find(params[:id])
    @all_notes = Note.find(:all,
                                  :conditions => ["user_id=:uid",{:uid=>@user.id}],
                                  :order => 'id desc',
                                  :page => {:size=>10,:current=>params[:page]})
    if @user.id != current_user.id
      @all_notes = @all_notes.find_all {|x| x.is_private == false}
    end

    @title = @user.login.capitalize + "'s Entire Notes:";
    render :action => :list_all_note
  end
  
  def list_all_personal_note
    @paper = Paper.find(params[:id])
    @all_notes = Note.find(:all,
                                  :conditions => ["user_id=:uid and paper_id=:pid",{:uid=>current_user.id,:pid=>@paper.id}],
                                  :order => 'id desc',
                                  :page => {:size=>10,:current=>params[:page]})
    
    @title = current_user.login.capitalize + "'s Entire Personal Notes on Paper '" + @paper.title + "':";
    render :action => :list_all_note   
  end
  
  
                                
  def list_all_public_note
    @paper = Paper.find(params[:id])
    @all_notes = Note.find(:all,
                                  :conditions => ["paper_id=:pid and is_private=:req",{:pid=>@paper.id,:req=>'false'}],
                                  :order => 'id desc',
                                  :page => {:size=>10,:current=>params[:page]}
                                  ) 
    @title = "All Public Notes on Paper '" + @paper.title + "':"
  render :action => :list_all_note                                    
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
    
    show_num = 5
    @public_notes = Note.find_all_by_paper_id_and_is_private(@paper.id, 'false')
    if(@public_notes.size > show_num)
      @public_notes = @public_notes[0,show_num]
      @public_notes_show_more = true
    else
      @public_notes_show_more = false
    end      
    
    @personal_notes = Note.find_all_by_paper_id_and_user_id(@paper.id, current_user.id)
    if(@personal_notes.size > show_num)
      @personal_notes = @personal_notes[0,show_num]
      @personal_notes_show_more = true
    else
      @personal_notes_show_more = false
    end       
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
