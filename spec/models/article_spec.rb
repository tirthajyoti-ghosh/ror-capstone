require 'rails_helper'
# rubocop:disable  Layout/LineLength

RSpec.describe Article, type: :model do
  let(:user) { User.create!(name: 'Example User', email: 'example@user.com', password: 'password', password_confirmation: 'password') }

  describe 'associations' do
    it { should belong_to(:author).class_name('User') }
    it { should have_many(:votes).dependent(:destroy) }
    it { should have_many(:categorizations).dependent(:destroy) }
    it { should have_many(:categories).through(:categorizations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:text) }
    it { should validate_presence_of(:image) }
    it { should validate_length_of(:title).is_at_least(5).is_at_most(50) }
    it { should validate_length_of(:text).is_at_least(10).is_at_most(35_000) }

    let(:article) { user.articles.build(title: 'Example Title01', text: 'Example text01', category_list: 'category1, category2') }

    it 'is expected to return false when invalid URL provided for image field' do
      article.image = 'invalid url'
      expect(article.valid?).to eq(false)
    end

    it 'is expected to return true when valid URL provided for image field' do
      article.image = 'https://example.com'
      expect(article.valid?).to eq(true)
    end
  end

  describe 'default scope' do
    let(:article1) { user.articles.create!(title: 'Example Title01', text: 'Example text01', image: 'https://example.com', category_list: 'category1, category2') }

    let(:article2) { user.articles.create!(title: 'Example Title02', text: 'Example text02', image: 'https://example.com', category_list: 'category1, category2') }

    it 'should return articles ordered by most recent' do
      expect(Article.all.to_sql).to eq(Article.order(created_at: :desc).to_sql)
    end
  end

  describe '#category_list=(category_string)' do
    let(:article) { user.articles.build(title: 'Example Title01', text: 'Example text01', image: 'https://example.com') }

    it 'should set the categories of the article' do
      article.category_list = 'category1, category2'
      article.save

      expect(article.categories.pluck(:name)).to eq(%w[Category1 Category2])
    end
  end

  describe '.already_voted?' do
    let(:article) { user.articles.create!(title: 'Example Title01', text: 'Example text01', image: 'https://example.com', category_list: 'category1, category2') }

    it 'returns true if given user already voted given article' do
      Vote.create!(user_id: user.id, article_id: article.id)

      expect(Article.already_voted?(article, user.id)).to eq(true)
    end

    it 'returns false if given user did not vote the given article' do
      user2 = User.create!(name: 'Example User02', email: 'example-2@user.com', password: 'password', password_confirmation: 'password')

      expect(Article.already_voted?(article, user2.id)).to eq(false)
    end
  end
end
# rubocop:enable  Layout/LineLength
