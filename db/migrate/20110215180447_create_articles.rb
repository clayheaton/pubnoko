class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string  :pubmedlink
      t.string  :article_title
      t.text    :abstract
      t.string  :authors
      t.text    :affiliations
      t.date    :pubdate
      t.integer :pubmedid
      t.integer :journal_id
      t.string  :journal_volume
      t.string  :journal_issue
      t.string  :journal_pages
      t.boolean :fetched
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
