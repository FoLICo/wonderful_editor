# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_article_id  (article_id)
#  index_comments_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Comment, type: :model do
  context "body を指定しているとき" do
    it "コメントが作られる" do
      comment = FactoryBot.build(:comment)
      expect(comment).to be_valid
    end
  end

  context "body を指定していないとき" do
    it "コメントの作成に失敗する" do
      comment = FactoryBot.build(:comment, body: nil)
      expect(comment).to be_invalid
      expect(comment.errors.details[:body][0][:error]).to eq :blank
    end
  end

  context "bodyが70文字以上の時のとき" do
    it "コメントの作成に失敗する" do
      comment = FactoryBot.build(:comment, body: "a" * 71)
      expect(comment).to be_invalid
      expect(comment.errors.details[:body][0][:error]).to eq :too_long
    end
  end
end
