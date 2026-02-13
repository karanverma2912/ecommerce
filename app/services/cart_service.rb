class CartService
  attr_reader :cart, :error

  def initialize(cart)
    @cart = cart
    @error = nil
  end

  def add_item(product_id, quantity = 1)
    product = Product.find_by(id: product_id)
    return error_response("Product not found") unless product

    if product.in_stock?
      @cart.add_product(product, quantity)
      true
    else
      @error = "Product is out of stock"
      false
    end
  end

  def update_item(item_id, quantity)
    cart_item = @cart.cart_items.find_by(id: item_id)
    return error_response("Item not found") unless cart_item

    if cart_item.update(quantity: quantity)
      @cart.recalculate_total!
      true
    else
      @error = cart_item.errors.full_messages
      false
    end
  end

  def remove_item(product_id)
    @cart.remove_product(product_id)
    true
  end

  def clear
    @cart.clear
    true
  end

  private

  def error_response(msg)
    @error = msg
    false
  end
end
