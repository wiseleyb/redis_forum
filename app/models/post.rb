class Post < Remodel::Entity

  has_one :user, :class => 'User', :reverse => :posts
  has_one :topic, :class => "Topic", :reverse => :posts
  has_one :forum, :class => "Forum", :reverse => :posts

  property :description, :class => 'String'
  property :created_at, :class => 'Time'
  property :updated_at, :class => 'Time'

  def update_counter(amt = 1)
    key = "counts:f:#{self.topic.id}:t:#{self.topic.id}:posts"
    amt > 0 ? Remodel.redis.incrby(key, amt) : Remodel.redis.decrby(key, amt.abs)
    key = "counts:f:#{self.forum.id}:posts"
    amt > 0 ? Remodel.redis.incrby(key, amt) : Remodel.redis.decrby(key, amt.abs)
    key = "lasts:f:#{self.forum.id}:last-post-id"
    Remodel.redis.set key, self.id
    key = "counts:u:#{self.user.id}:posts"
    amt > 0 ? Remodel.redis.incrby(key, amt) : Remodel.redis.decrby(key, amt.abs)
  end


  def self.new_from_params(params)
    fid = params[:post].delete(:forum)
    forum = Forum.find(fid.to_i)
    tid = params[:post].delete(:topic)
    topic = Topic.find(tid.to_i)
    uid = params[:post].delete(:user)
    user = User.find(uid)
    post = Post.new(params[:post])
    post.save
    post.user = user
    post.user.save
    post.forum = forum
    post.forum.save
    post.topic = topic
    post.topic.save
    post.update_counter
    return topic
  end

end

