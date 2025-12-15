
# app/serializers/product_detail_serializer.rb
class ProductDetailSerializer < ProductSerializer
  has_one :category, serializer: CategorySerializer
  has_many :reviews, serializer: ReviewSerializer
end
