require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :realname
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 1..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 0..100
  validates_uniqueness_of   :login, :case_sensitive => false
  before_save :encrypt_password

  has_many :collections, :dependent => :destroy
  has_many :papers, :through => :collections, :select => "distinct papers.*"
  has_many :tags, :through => :collections, :select => "distinct tags.*"
  has_many :notes, :dependent => :destroy

  def popular_tags(limit=5)
    #~ tags = Collection.find(:all,
                                    #~ :select => 'name, count(tag_id) as tag_amount, t.id as id, c.paper_id as paper_id',
                                    #~ :order => 'tag_amount desc',
                                    #~ :group => 'tag_id',
                                    #~ :limit => limit,
                                    #~ :joins => 'as c inner join tags as t on c.tag_id=t.id',
                                    #~ :conditions => ["paper_id=:p_id",{:p_id=>self.id}])
    #performance problem
    tags = (self.tags.map{|t| {:name=>t.name, :id=>t.id, :tag_amount=>t.collections.count}}).sort {|t1,t2| t2[:tag_amount]<=>t1[:tag_amount]} [0,limit]
  end
                                  
  def self.role_list
    return ['Common User', 'Administrator']
  end


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
