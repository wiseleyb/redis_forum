class Topic < Remodel::Entity

  has_many :posts, :class => "Post", :reverse => :topic
  has_one :forum, :class => "Forum", :reverse => :topics
  has_one :user, :class => "User", :reverse => :topics

  property :title, :class => 'String'
  property :description, :class => 'String'
  property :created_at, :class => 'Time'
  property :updated_at, :class => 'Time'

  def update_counter(amt = 1)
    key = "counts:f:#{self.forum.id}:topics"
    amt > 0 ? Remodel.redis.incrby(key, amt) : redis.decrby(key, amt.abs)
    key = "counts:u:#{self.user.id}:topics"
    amt > 0 ? Remodel.redis.incrby(key, amt) : Remodel.redis.decrby(key, amt.abs)
  end

  def post_count
    key = "counts:f:#{self.forum.id}:t:#{self.id}:posts"
    Remodel.redis.get key
  end

  def self.new_from_params(params)
    fid = params[:topic].delete(:forum)
    forum = Forum.find(fid.to_i)
    uid = params[:topic].delete(:user)
    user = User.find(uid)
    topic = Topic.new(params[:topic])
    topic.save
    topic.user = user
    topic.user.save
    topic.forum = forum
    topic.forum.save
    topic.update_counter
    return topic
  end

  def self.destroy_all
    Remodel.redis.keys("t*").split(" ").each do |k|; Remodel.redis.del(k); end
    Remodel.redis.keys("u:*:topics").split(" ").each do |k|; Remodel.redis.del(k); end
  end

end
