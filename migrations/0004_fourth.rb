require './mnt'

Sequel.migration do
  create_table :tags do
    primary_key :id
    String :name, unique: true

    index :name
  end

  create_table :taggings do
    primary_key :id
    foreign_key :tag_name, :tags, key: :id, type: 'varchar(255)'
    foreign_key :status_id, :status, key: :id
  end
end
