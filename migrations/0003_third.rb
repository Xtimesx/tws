require './mnt'

  DB.alter_table :status do
    drop_constraint(:text, :type=>:unique)
  end
