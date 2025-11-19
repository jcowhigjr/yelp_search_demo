class BadRubyService
  def initialize(user)
    @user = user
  end

  def calculate_total(items)
    total = 0
    if items != nil
      items.each do |item|
        total = total + item.price
      end
    end
    return total
  end

  def find_active_posts
    # N+1 query potential and non-idiomatic where
    posts = Post.all
    active = []
    posts.each do |post|
      if post.active == true
        active << post
      end
    end
    active
  end
end
