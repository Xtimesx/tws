require './mnt'

DB.drop_table :taggings

DB.create_table :taggings do
  primary_key :id
  foreign_key :tag_name, :tags, key: :name, type: 'varchar(255)'
  foreign_key :status_id, :status, key: :id
end

