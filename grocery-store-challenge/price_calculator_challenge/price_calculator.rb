class Item
  attr_accessor :name, :price

  @@items = []
  def initialize(name=nil,price=nil)
    if !name.nil?
      @@items << {
        "name" => name,
        "price" => price
      }
    end
    @items_list = []
  end

  def get_items
    puts "Please enter all the items purchased separated by a comma"
    @items_puchased = gets.chop.downcase
    @items_puchased = @items_puchased.split(",").map(&:strip)
    if @items_puchased.empty?
      get_items
    else
      invalid_items = valdate_items @items_puchased
      if invalid_items.any?
        puts "Items not present - #{invalid_items.join(",")}"
        get_items
      else
        get_items_data
      end
    end
  end

  def get_items_data
    @items_puchased.uniq.each do |item|
      item_list = {}
      item_list["name"] = item
      quantity = @items_puchased.count(item)
      item_list["quantity"] = quantity
      item_price,saved_amount = calculate_price(item,quantity)
      item_list["price"] = item_price
      item_list["saved_amount"] = saved_amount 
      @items_list << item_list
    end
    print_bill
  end

  def calculate_price item, quantity
    price_data = get_items_price item
    sales_data = get_sales_data(item)
    undiscounted_quantity = quantity%sales_data[item]["units"] rescue quantity
    sale_amount = ((quantity/sales_data[item]["units"].to_i)*sales_data[item]["price"]).to_f rescue 0
    item_price = ((undiscounted_quantity*price_data["price"])+sale_amount).to_f
    saved_amount = (quantity*price_data["price"] - item_price).round(3)
    return item_price,saved_amount
  end

  private

  def valdate_items items
    invalid_items = (items - @@items.collect{|k| k["name"]})
    return invalid_items
  end

  def get_items_price item
    items_data = @@items.detect{|i| i["name"] == item.to_s}   
    return items_data
  end

  def get_sales_data name
    sale_data = SaleItem.sales_items
    return sale_data.select{|k,v| k == name}
  end

  def print_bill
    puts "Items      Quantity      Price"
    puts "-----------------------------------"
    @items_list.each do |item|
      puts "#{item["name"].ljust(13)} #{item["quantity"]}          #{item["price"]}"
    end
    total_price = @items_list.reduce(0) {|sum,i| sum + i["price"]}.round(3)
    saved_amount = @items_list.reduce(0) {|sum,i| sum + i["saved_amount"]}.round(3)
    puts "\n"
    puts "Total Price : $#{total_price}"
    puts "You saved $#{saved_amount} today."
  end
    
end

class SaleItem
  attr_accessor :name, :price, :units

  @@sale_items = {}
  def initialize(name,units,price)
    @@sale_items[name] = {
      "units" => units,
      "price" => price
    }
  end

  def self.sales_items
    @@sale_items
  end

end

begin
  # creating sales items
  SaleItem.new("milk",2,5)
  SaleItem.new("bread",3,6)

  # creating items in store
  Item.new('milk', 3.97)
  Item.new('bread', 2.17)
  Item.new('banana', 0.99)
  Item.new('apple', 0.89)
  Item.new.get_items
end
