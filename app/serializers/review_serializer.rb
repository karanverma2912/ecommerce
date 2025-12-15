# app/serializers/review_serializer.rb
class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :rating, :comment, :user_name, :created_at, :comments_count

  belongs_to :user, serializer: UserSerializer
  has_many :comments, serializer: CommentSerializer

  def user_name
    object.user.full_name
  end

  def comments_count
    object.comments.count
  end
end
