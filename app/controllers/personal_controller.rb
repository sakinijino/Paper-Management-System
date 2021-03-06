class PersonalController < ApplicationController
  layout 'frame'
  include AuthenticatedSystem
  before_filter :login_required, 
    :except => [ :list_collection, :list_tagged_paper, :list_all_paper, :list_all_my_note, :list_all_public_note, :show_paper_detail]
  
  verify :method => :post, :only => [ :add_to_collection, :remove_from_collection, :create_note, :destroy_note],
          :redirect_to => { :action => :list_collection }
  
  def add_to_collection
    paper = Paper.find(params[:id])
    params[:tags].strip!
    params[:tags] = "" if params[:tags] ==nil

    Collection.destroy_all(:user_id=>current_user.id, :paper_id=>paper.id)
    
    if params[:tags] == ""
        collection = Collection.new
        collection.paper = paper
        collection.user = current_user
        collection.tag = nil
        collection.status = params[:status]
        collection.save
    else
      for tag_name in params[:tags].split.uniq
        tag_name.strip!
        next if tag_name==""
        tag = Tag.find_by_name(tag_name)
        if tag == nil
          tag = Tag.create({:name => tag_name})
          if tag == nil
            next
          end
        end
        collection = Collection.new
        collection.paper = paper
        collection.user = current_user
        collection.tag = tag
        collection.status = params[:status]
        collection.save
      end
    end
    Tag.clear_redundances
    redirect_to :action=>'show_paper_detail',:id=> paper.id
  end
  
  def remove_from_collection
    paper = Paper.find(params[:id])
    Collection.destroy_all(:user_id=>current_user.id, :paper_id=>paper.id)
    Tag.clear_redundances
    redirect_to :action=>'show_paper_detail',:id=> paper.id
  end
  
  def list_collection
    @user = User.find(params[:id]) if params[:id]!=nil
    @user = current_user if params[:id]==nil
    
    show_num = 5
    @to_read_papers = Paper.find(:all,
                                    :select => 'p.*',
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
                                    :select => 'p.*',
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
                                    :select => 'p.*',
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
    if (!logged_in? || @user.id != current_user.id)
      @my_notes = @my_notes.find_all {|x| x.is_private == 0}
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
                                  :select => 'papers.*',
                                  :conditions => ["c.user_id=:uid and c.status=:status",{:uid=>@user.id, :status=>@status}],
                                  :order => 'c.id desc',
                                  :group => 'paper_id',
                                  :joins => 'inner join collections as c on papers.id=c.paper_id',
                                  :page => {:size=>10,:current=>params[:page]})   
  end
                                
  def list_tagged_paper
    @tag = Tag.find(params[:id])
    @user = User.find(params[:uid])
    
    unpaged_papers = Paper.find(
                                      :all,
                                      :select => 'papers.*',
                                      :conditions => ["c.user_id=:uid and c.tag_id=:tag_id",{:uid=>@user.id, :tag_id=>@tag.id}],
                                      :joins => 'inner join collections as c on c.paper_id=papers.id'
                                      )
    
    if params[:sort] == 'pub_date'
      @papers = Paper.find(
                                      :all, :select => 'papers.*',
                                      :conditions => ["c.user_id=:uid and c.tag_id=:tag_id",{:uid=>@user.id, :tag_id=>@tag.id}],
                                      :order => 'publish_time desc',
                                      :joins => 'inner join collections as c on c.paper_id=papers.id',
                                      :page => {:size=>10,:current=>params[:page]}
                                    )
    else
      @papers = Paper.find(:all, 
                                    :select => 'papers.*',
                                    :conditions => ["c.user_id=:uid and c.tag_id=:tag_id",{:uid=>@user.id, :tag_id=>@tag.id}],
                                    :order => 'c.id desc',
                                    :group => 'paper_id',
                                    :joins => 'inner join collections as c on papers.id=c.paper_id',
                                    :page => {:size=>10,:current=>params[:page]}
                                  )
    end                                    
    #这里需要用join重写，如果性能有问题的话
    @related_tags = Array.new
    @related_tags_counts = []
    for other_tag in @user.tags - [@tag]
      if (unpaged_papers & other_tag.papers).empty? == false
        @related_tags << other_tag
        @related_tags_counts << other_tag.collections.count
      end
    end

  end                                

  def list_all_my_note
    @user = User.find(params[:id])
    if @user.id == current_user.id
      @all_notes = Note.find(:all,
                                    :conditions => ["user_id=:uid",{:uid=>@user.id}],
                                    :order => 'id desc',
                                    :page => {:size=>10,:current=>params[:page]})
    else
      @all_notes = Note.find(:all,
                                    :conditions => ["user_id=:uid and is_private=:req",{:uid=>@user.id,:req=>0}],
                                    :order => 'id desc',
                                    :page => {:size=>10,:current=>params[:page]})      
    end

    @title = @user.realname.capitalize + "'s Entire Notes:";
    @show_paper_title = true
    render :action => :list_all_note
  end
  
  def list_all_personal_note
    @paper = Paper.find(params[:id])
    @all_notes = Note.find(:all,
                                  :conditions => ["user_id=:uid and paper_id=:pid",{:uid=>current_user.id,:pid=>@paper.id}],
                                  :order => 'id desc',
                                  :page => {:size=>10,:current=>params[:page]})
    
    @title = current_user.realname.capitalize + "'s Entire Personal Notes on '" + @paper.title + "':";
    @show_paper_title = false
    render :action => :list_all_note    
  end
  
  
                                
  def list_all_public_note
    @paper = Paper.find(params[:id])
    @all_notes = Note.find(:all,
                                  :conditions => ["paper_id=:pid and is_private=:req",{:pid=>@paper.id,:req=>0}],
                                  :order => 'id desc',
                                  :page => {:size=>10,:current=>params[:page]}
                                  ) 
    @title = "All Public Notes on '" + @paper.title + "':"
    @show_paper_title = false
    render :action => :list_all_note                                    
 end                              
                                

  
  def show_paper_detail
    @paper = Paper.find(params[:id])

    if logged_in?
      @tags = Collection.find(:all,
                              :conditions => ["user_id=:uid and paper_id=:pid",{:uid=>current_user.id, :pid=>@paper.id}],
                              :select => 't.name,t.id, c.paper_id, c.user_id, c.status',
                              :joins => 'as c inner join tags as t on c.tag_id=t.id')
      if @tags.empty?
        c= Collection.find_by_user_id_and_paper_id(current_user.id, @paper.id)
        if c != nil
          @collected_status = c.status
        else
          @collected_status = nil
        end
      else
        @collected_status = @tags[0].status
      end
    end

    show_num = 3
    @public_notes = Note.find_all_by_paper_id_and_is_private(@paper.id, 0)
    if(@public_notes.size > show_num)
      @public_notes = @public_notes[0,show_num]
      @public_notes_show_more = true
    else
      @public_notes_show_more = false
    end      
    
    if logged_in?
      @personal_notes = Note.find_all_by_paper_id_and_user_id(@paper.id, current_user.id)
      if(@personal_notes.size > show_num)
        @personal_notes = @personal_notes[0,show_num]
        @personal_notes_show_more = true
      else
        @personal_notes_show_more = false
      end       
    end
  end

  def create_note
    note = Note.new(params[:note])
    note.user_id = current_user.id
    note.paper_id = params[:id]
    note.publish_time = Time.now
    
    if note.save
      redirect_to :action => 'show_paper_detail', :id => note.paper_id
    else
      redirect_to :action => 'show_paper_detail', :id => note.paper_id
    end      
  end
  
  #~ def edit_note
    #~ @note = Note.find(params[:id])
  #~ end
  
  #~ def update_note
    #~ @note = Note.find(params[:id])
    #~ if @note.update_attributes(params[:note])
      #~ flash[:notice] = 'Note has been successfully updated.'
      #~ redirect_to :action => 'show_paper_detail', :id => @note.paper_id
    #~ else
      #~ redirect_to :action => 'show_paper_detail', :id => @note.paper_id
    #~ end
  #~ end
  
  def destroy_note
    note = Note.find(params[:id])
    pid = note.paper_id
    note.destroy
    redirect_to :action => 'show_paper_detail', :id => pid
  end
end
