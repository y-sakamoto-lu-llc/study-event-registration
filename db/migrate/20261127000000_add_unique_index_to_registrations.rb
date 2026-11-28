class AddUniqueIndexToRegistrations < ActiveRecord::Migration[8.1]
  def up
    duplicates = select_rows(<<~SQL)
      SELECT user_id, event_id, COUNT(*)
      FROM registrations
      GROUP BY user_id, event_id
      HAVING COUNT(*) > 1
      ORDER BY event_id, user_id
    SQL

    if duplicates.any?
      details = duplicates.map { |user_id, event_id, count| "  event_id=#{event_id} user_id=#{user_id} (#{count} 件)" }.join("\n")
      raise <<~MSG
        同じ user_id と event_id の組み合わせの登録が重複しているため、一意インデックスを追加できません。
        データは変更していません。重複を確認して整理してから、もう一度実行してください。
        #{details}
      MSG
    end

    add_index :registrations, %i[user_id event_id], unique: true
  end

  def down
    remove_index :registrations, %i[user_id event_id]
  end
end
