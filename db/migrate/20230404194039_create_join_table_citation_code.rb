class CreateJoinTableCitationCode < ActiveRecord::Migration[7.0]
  def change
    create_join_table :citations, :codes do |t|
      # t.index [:citation_id, :code_id]
      # t.index [:code_id, :citation_id]
    end
  end
end
