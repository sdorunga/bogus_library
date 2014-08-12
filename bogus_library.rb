require 'pry'
class User
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def join_library(library)
    library.sign_up_user(self)
  end
end

class Library
  attr_reader :users
  def initialize(books)
    @books = books
    @users = {}
  end

  def sign_up_user(user)
    @users[user.name] = LibraryCard.new unless @users[user.name]
  end

  def checkout_book(book_name, user)
    library_card = library_card_for(user.name)
    return [] if library_card.borrowing_limit_reached?

    book = find_book(book_name)
    library_card.check_out(book)
  end

  def return_book(book_name, user)
    library_card = library_card_for(user.name)
    book = find_book(book_name)

    library_card.return_book(book)
  end

  private

  def find_book(book_name)
    @books.select { |book| book[:name] == book_name }
  end

  def library_card_for(name)
    @users[name]
  end
end

class LibraryCard
  attr_reader :limit

  def initialize(limit=nil)
    @limit = limit || 2
    @checked_out = []
  end

  def check_out(book)
    @checked_out += book
  end

  def return_book(book)
    @checked_out -= book
  end

  def borrowing_limit_reached?
    @checked_out.count == @limit
  end
end

#user = User.new("Larry") # => #<User:0x007f839a8b9938 @name="Larry">
#library = Library.new([{ name: "Moby Dick", length: 230}, { name: "Green Eggs & Ham", length: 210}]) # => #<Library:0x007f839a8b9640 @books=[{:name=>"Moby Dick", :length=>230}, {:name=>"Green Eggs & Ham", :length=>210}], @users={}>
#user.join_library(library) # => #<LibraryCard:0x007f839a8b8ec0 @limit=2, @checked_out=["a"]>
#library # => #<Library:0x007f839a8b9640 @books=[{:name=>"Moby Dick", :length=>230}, {:name=>"Green Eggs & Ham", :length=>210}], @users={"Larry"=>#<LibraryCard:0x007f839a8b8ec0 @limit=2, @checked_out=["a"]>}>
#library.checkout_book("Moby Dick", user) # => ["a", {:name=>"Moby Dick", :length=>230}]
#library.checkout_book("Green Eggs & Ham", user) # => []
#library.return_book("Moby Dick", user) # => ["a"]
#library.checkout_book("Green Eggs & Ham", user) # => ["a", {:name=>"Green Eggs & Ham", :length=>210}]
