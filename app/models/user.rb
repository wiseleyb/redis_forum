class User < Remodel::Entity

  has_many :forums, :class => 'Forum', :reverse => :user
  has_many :topics, :class => "Topic", :reverse => :user
  has_many :posts, :class => "Post", :reverse => :user
  has_many :roles, :class => "Role", :reverse => :user

  property :login, :class => 'String'
  property :name, :class => 'String'
  property :created_at, :class => 'Time'
  property :updated_at, :class => 'Time'

  def post_count
    Remodel.redis.get "counts:u:#{self.id}:posts"
  end

  def topic_count
    Remodel.redis.get "counts:u:#{self.id}:topics"
  end

end

