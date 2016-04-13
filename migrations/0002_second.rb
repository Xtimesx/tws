require './mnt'

Sequel.migration do
  alter_table :media do
    add_column :local_path, String
  end
end
