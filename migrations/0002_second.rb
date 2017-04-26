require './mnt'

  DB.alter_table :media do
    add_column :local_path, String
  end
