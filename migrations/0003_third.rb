require './mnt'

Sequel.migration do
  alter_table :status do
    drop_constraint(:text, :type=>:unique)
  end
end
