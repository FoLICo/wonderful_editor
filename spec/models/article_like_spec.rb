# == Schema Information
#
# Table name: article_likes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_article_likes_on_article_id              (article_id)
#  index_article_likes_on_article_id_and_user_id  (article_id,user_id) UNIQUE
#  index_article_likes_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe ArticleLike, type: :model do
  context "article_idとuser_id を指定しているとき" do
    let(:user) { create(:user) }
    let(:article) { create(:article) }

    it "いいねができる" do
      article_like = ArticleLike.create!(user_id: user.id, article_id: article.id)
      expect(article_like).to be_valid
    end
  end

  context "article_id を指定していないとき" do
    let(:user) { create(:user) }
    let(:article) { create(:article) }

    it "いいねができない" do
      article_like = ArticleLike.create(user_id: user.id, article_id: nil)
      expect(article_like).to be_invalid
      expect(article_like.errors.details[:article][0][:error]).to eq :blank
      expect(article_like.errors.details[:article_id][0][:error]).to eq :blank
    end
  end

  context "user_id を指定していないとき" do
    let(:user) { create(:user) }
    let(:article) { create(:article) }

    it "いいねができない" do
      article_like = ArticleLike.create(user_id: nil, article_id: article.id)
      expect(article_like).to be_invalid
      expect(article_like.errors.details[:user][0][:error]).to eq :blank
      expect(article_like.errors.details[:user_id][0][:error]).to eq :blank
    end
  end

  context "指定したarticle_idに既にuser_idがあるとき" do
    before { ArticleLike.create(user_id: user.id, article_id: article.id) }

    let(:user) { create(:user) }
    let(:article) { create(:article) }
    it "いいねができない" do
      subject = ArticleLike.create(user_id: user.id, article_id: article.id)
      expect(subject).to be_invalid
      expect(subject.errors.details[:article_id][0][:error]).to eq :taken
    end
  end
end
