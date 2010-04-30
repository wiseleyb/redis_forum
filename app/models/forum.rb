class Forum < Remodel::Entity

  has_many :topics, :class => "Topic", :reverse => :forum
  has_many :posts, :class => "Post", :reverse => :forum
  has_one :user, :class => "User", :reverse => :forums

  property :title, :class => 'String'
  property :description, :class => 'String'
  property :created_at, :class => 'Time'
  property :updated_at, :class => 'Time'

  def topic_count
    key = "counts:f:#{self.id}:topics"
    Remodel.redis.get key
  end

  def post_count
    key = "counts:f:#{self.id}:posts"
    Remodel.redis.get key
  end

  def last_post
    key = "lasts:f:#{self.id}:last-post-id"
    pid = Remodel.redis.get(key)
    Post.find(pid.to_i) if pid
  end

  def last_post_date
    lp = last_post
    lp.created_at if lp
  end

  def self.new_from_params(params)
    uid = params[:forum].delete(:user)
    u = User.find(uid.to_i)
    forum = Forum.new(params[:forum])
    forum.save
    forum.user = u
    forum.user.save
    return forum
  end

  def self.destroy_all
    Remodel.redis.keys("f*").split(" ").each do |k|; Remodel.redis.del(k); end
    Remodel.redis.keys("u:*:forums").split(" ").each do |k|; Remodel.redis.del(k); end
  end

end
