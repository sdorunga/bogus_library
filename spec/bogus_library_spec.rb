require 'simplecov'
SimpleCov.start do
  add_filter "vendor"
  add_group "Library", 'app'
end
require_relative "../bogus_library"
require 'rspec'
require 'pry'

RSpec.describe User do
  let(:name) { "Joe" }
  let(:library) { double("Library") }
  subject    { described_class.new(name) }

  it 'has a name' do
    expect(subject.name).to eq(name)
  end

  it 'can join a library' do
    expect(library).to receive(:sign_up_user).with(subject)

    subject.join_library(library)
  end
end

RSpec.describe LibraryCard do
  let(:default_limit) { 2 }
  let(:limit) { nil }
  let(:book) { [{ name: "Book" }] }
  let(:book2) { [{ name: "Book 2" }] }
  subject { described_class.new(limit) }

  describe '#limit' do
    it 'has a default limit' do
      expect(subject.limit).to eq(default_limit)
    end

    context 'when passing in a limit' do
      let(:limit) { 3 }

      it 'uses the supplied limit' do
        expect(subject.limit).to eq(limit)
      end
    end
  end

  describe '#check_out' do

    it 'returns a list of checked out books' do
      expect(subject.check_out(book)).to eq(book)
    end
  end

  describe '#check_out' do
    before do 
      subject.check_out(book)
      subject.check_out(book2)
    end

    it 'returns a list of remaining books' do
      expect(subject.return_book(book)).to eq(book2)
    end
  end

  describe '#borrowing_limit_reached?' do
    context 'with one book checked out' do
      before do 
        subject.check_out(book)
      end

      it 'returns a list of remaining books' do
        expect(subject.borrowing_limit_reached?).to be(false)
      end
    end

    context 'with two books checked out' do
      before do 
        subject.check_out(book)
        subject.check_out(book2)
      end

      it 'returns a list of remaining books' do
        expect(subject.borrowing_limit_reached?).to  be(true)
      end
    end
  end
end

RSpec.describe Library do
  let(:user)  { double("User", name: "Joe") }
  let(:book1) { { name: "Old man and the sea" } }
  let(:book2) { { name: "The girl with the striped earrings" } }
  subject { described_class.new([book1, book2]) }
  
  describe "#sign_up_user" do
    it 'adds a library card for the user' do
      subject.sign_up_user(user)

      expect(subject.users[user.name]).to be_kind_of(LibraryCard)
    end
  end

  describe "#checkout_book" do
    let(:library_card) { double("LibraryCard", borrowing_limit_reached?: false, check_out: nil) }
    before do
      allow(LibraryCard).to receive(:new).and_return(library_card)
      subject.sign_up_user(user)
    end

    it 'adds the book to the library card' do
      subject.checkout_book("Old man and the sea", user)

      expect(library_card).to receive(:check_out)#.with([book1])
    end

    context 'when the borrowing limit is reached' do
      before do
        allow(library_card).to receive(:borrowing_limit_reached?).and_return(true)
      end

      it 'does not add the book to the library card' do
        subject.checkout_book("Old man and the sea", user)

        expect(library_card).to_not receive(:check_out).with([book1])
      end
    end
  end

  describe "#return_book" do
    let(:library_card) { double("LibraryCard", borrowing_limit_reached?: false, check_out: nil) }
    before do
      allow(LibraryCard).to receive(:new).and_return(library_card)
      subject.sign_up_user(user)
      subject.checkout_book("Old man and the sea", user)
      subject.checkout_book("The girl with the striped earrings", user)
    end

    it 'returns an empty array' do
      allow(library_card).to receive(:check_out).with([book1]).and_return([book1])

      expect(subject.return_book("Old man and the sea", user)).to eq([book1])
    end
  end
end
