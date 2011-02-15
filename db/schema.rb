# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110215180536) do

  create_table "articles", :force => true do |t|
    t.string   "pubmedlink"
    t.string   "article_title"
    t.text     "abstract"
    t.string   "authors"
    t.text     "affiliations"
    t.date     "pubdate"
    t.integer  "pubmedid"
    t.integer  "journal_id"
    t.string   "journal_volume"
    t.string   "journal_issue"
    t.string   "journal_pages"
    t.boolean  "fetched"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journals", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
