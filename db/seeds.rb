# db/seeds.rb

require 'faker'

puts "Clearing existing data..."

ActiveRecord::Base.connection.disable_referential_integrity do
  Wishlist.delete_all
  Comment.delete_all
  Review.delete_all
  OrderItem.delete_all
  Order.delete_all
  CartItem.delete_all
  Cart.delete_all
  Product.delete_all
  Category.delete_all
  User.delete_all
end

puts "Resetting primary key sequences..."

ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.reset_pk_sequence!(table)
end

puts "Seeding users..."

# Admin user
admin = User.create!(
  email: 'admin@ecommerce.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  is_admin: true,
  address: Faker::Address.street_address,
  city: Faker::Address.city,
  state: Faker::Address.state,
  zip_code: Faker::Address.zip_code,
  country: Faker::Address.country,
  phone: Faker::PhoneNumber.cell_phone_in_e164
)

# Regular users
users = []
50.times do
  users << User.create!(
    email: Faker::Internet.unique.email,
    password: 'password123',
    password_confirmation: 'password123',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state,
    zip_code: Faker::Address.zip_code,
    country: Faker::Address.country,
    phone: Faker::PhoneNumber.cell_phone_in_e164
  )
end

all_users = users + [ admin ]

puts "Seeding categories..."

category_names = [
  'Electronics',
  'Mobiles & Tablets',
  'Laptops & Computers',
  'Home & Kitchen',
  'Fashion',
  'Books',
  'Gaming',
  'Health & Personal Care'
]

categories = category_names.map do |name|
  Category.create!(
    name: name,
    description: Faker::Lorem.sentence(word_count: 10),
    slug: name.downcase.gsub(/[^a-z0-9]+/, '-').chomp('-'),
    is_active: true
  )
end

puts "Seeding products..."

products = []

categories.each do |category|
  rand(8..15).times do
    products << Product.create!(
      name: Faker::Commerce.unique.product_name,
      description: Faker::Lorem.paragraph(sentence_count: 4),
      price: Faker::Commerce.price(range: 199.0..49_999.0),
      sku: Faker::Alphanumeric.unique.alphanumeric(number: 10).upcase,
      quantity_in_stock: rand(0..100),
      discount_percentage: [ 0, 5, 10, 15, 20 ].sample,
      is_active: [ true, true, true, false ].sample,
      category_id: category.id
    )
  end
end

puts "Seeding wishlists..."

all_users.each do |user|
  products.sample(rand(3..8)).each do |product|
    Wishlist.find_or_create_by!(user_id: user.id, product_id: product.id)
  end
end

puts "Seeding carts and cart_items..."

all_users.each do |user|
  cart = Cart.create!(user_id: user.id, total_price: 0)

  products.sample(rand(1..5)).each do |product|
    quantity = rand(1..3)
    price = product.price || Faker::Commerce.price(range: 199.0..49_999.0)

    CartItem.create!(
      cart_id: cart.id,
      product_id: product.id,
      quantity: quantity,
      price: price
    )
  end

  cart.recalculate_total!  # uses Cart method, no recursion
end

puts "Seeding ordercategory_namess and order_items..."

status_values = Order.statuses.keys # ["pending", "processing", "shipped", "delivered", "cancelled"]
payment_status_values = Order.payment_statuses.keys # ["pending", "paid", "failed", "refunded"]

all_users.each do |user|
  rand(2..5).times do
    order_status = status_values.sample
    payment_status = if order_status == 'delivered'
                       'paid'
    else
                       payment_status_values.sample
    end

    order = Order.create!(
      user_id: user.id,
      total_amount: 1,
      shipping_address: [
        Faker::Address.street_address,
        Faker::Address.city,
        Faker::Address.state,
        Faker::Address.zip_code,
        Faker::Address.country
      ].join(', '),
      status: order_status,
      payment_status: payment_status,
      payment_method: %w[card upi netbanking cod].sample,
      stripe_payment_id: (payment_status == 'paid' ? "pi_#{Faker::Alphanumeric.alphanumeric(number: 14)}" : nil)
    )

    selected_products = products.sample(rand(1..4))
    order_total = 0

    selected_products.each do |product|
      quantity = rand(1..3)
      price = product.price || Faker::Commerce.price(range: 199.0..49_999.0)

      OrderItem.create!(
        order_id: order.id,
        product_id: product.id,
        quantity: quantity,
        price: price
      )

      order_total += price * quantity
    end

    order.update!(total_amount: order_total)
  end
end

puts "Seeding reviews and comments..."

products.sample(30).each do |product|
  # Ensure each user reviews a product at most once due to unique index
  reviewers = all_users.sample(rand(1..5)).uniq

  reviewers.each do |user|
    review = Review.create!(
      user_id: user.id,
      product_id: product.id,
      rating: rand(1..5),
      comment: Faker::Lorem.paragraph(sentence_count: 3)
    )

    # Comments on review
    rand(0..3).times do
      Comment.create!(
        review_id: review.id,
        user_id: all_users.sample.id,
        content: Faker::Lorem.sentence(word_count: 12)
      )
    end
  end
end

puts "✅ Seeding completed successfully!"
puts "Users: #{User.count}"
puts "Categories: #{Category.count}"
puts "Products: #{Product.count}"
puts "Wishlists: #{Wishlist.count}"
puts "Carts: #{Cart.count}"
puts "CartItems: #{CartItem.count}"
puts "Orders: #{Order.count}"
puts "OrderItems: #{OrderItem.count}"
puts "Reviews: #{Review.count}"
puts "Comments: #{Comment.count}"
