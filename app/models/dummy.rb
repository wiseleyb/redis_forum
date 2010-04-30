class Dummy

  def random_dates(obj)
    obj.created_at = Time.now - (rand 365).days
  end

  def random_user(obj)
    obj.user = @users[rand @users.size]
  end

  def gen_data
    Remodel.redis.flushall
    arr = []
    File.open("db/names.txt") {|f|
      arr << f.read
    }
    arr = arr.first.split("\n")
    users = []
    arr.each do |a|
      ln = a.split(" ").last
      u = User.new :login => ln, :name => a
      random_dates(u)
      u.save
      users << u
    end
    @users = users

    forums = []
    50.times do |i|
      f = Forum.new :title => "Forum #{i}", :description => "All about forum #{i}"
      f.save
      random_dates(f)
      random_user(f)
      f.user.save
      forums << f
    end

    forums.each do |f|
      topics = []
      (rand 30).times do |i|
        t = Topic.new :title => "Topic #{i} for Forum #{f.id}"
        t.save
        topics << t
        random_dates(t)
        random_user(t)
        t.user.save
        t.forum = f
        t.forum.save
        t.update_counter
        t.save
        (rand 100).times do |j|
          p = Post.new :description => "Post #{j} for Topic #{i} for Forum #{f.id}"
          p.save
          random_dates(p)
          random_user(p)
          p.user.save
          p.topic = t
          p.topic.save
          p.forum = f
          p.forum.save
          p.update_counter
          p.save
        end
      end
    end
    Remodel.redis.bgsave
  end

end