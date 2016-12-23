# frozen_string_literal: true
class DropImplStaticAttributes < ActiveRecord::Migration
  def change
    drop_table :impl_static_attributes
  end
end
