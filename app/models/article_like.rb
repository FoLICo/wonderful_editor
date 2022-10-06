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
class ArticleLike < ApplicationRecord
  validates :article_id, uniqueness: { scope: :user_id }
  belongs_to :user
  belongs_to :article
end
