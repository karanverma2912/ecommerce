# app/serializers/comment_serializer.rb
class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :user_name, :created_at

  belongs_to :user, serializer: UserSerializer

  def user_name
    object.user.full_name
  end
end
