class MakeChiefInstructorUniquePerGroupSemester < ActiveRecord::Migration
  def up
    add_column :group_semesters, :group_instructor_id, :integer

    groups = execute 'SELECT id FROM groups ORDER BY id'
    semesters = execute 'SELECT id FROM semesters ORDER BY id'
    groups.each do |g|
      semesters.each do |s|
        if execute("SELECT id FROM group_semesters WHERE group_id = #{g['id']} AND semester_id = #{s['id']}").empty?
          execute "INSERT INTO group_semesters(group_id, semester_id, created_at, updated_at) VALUES (#{g['id']}, #{s['id']}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
        end
      end
    end

    execute "UPDATE group_semesters gs SET group_instructor_id =
        (SELECT gi.id FROM group_instructors gi
            INNER JOIN group_schedules gsc ON gsc.id = gi.group_schedule_id
            WHERE gi.semester_id = gs.semester_id
                AND gsc.group_id = gs.group_id
                AND role = 'Hovedinstruktør' LIMIT 1)
        WHERE group_instructor_id IS NULL"

    execute "UPDATE group_semesters gs SET group_instructor_id =
        (SELECT gi.id FROM group_instructors gi
            INNER JOIN group_schedules gsc ON gsc.id = gi.group_schedule_id
            WHERE gi.semester_id = gs.semester_id
                AND gsc.group_id = gs.group_id
                AND role = 'Instruktør' LIMIT 1)
        WHERE group_instructor_id IS NULL"

    execute 'UPDATE group_semesters gs SET group_instructor_id =
        (SELECT gi.id FROM group_instructors gi
            INNER JOIN group_schedules gsc ON gsc.id = gi.group_schedule_id
            WHERE gi.semester_id = gs.semester_id
                AND gsc.group_id = gs.group_id LIMIT 1)
        WHERE group_instructor_id IS NULL'

    add_column :group_instructors, :group_semester_id, :integer
    execute 'UPDATE group_instructors gi
        SET group_semester_id =
        (SELECT gs.id FROM group_semesters gs
            INNER JOIN group_schedules gsc ON gsc.id = gi.group_schedule_id
            WHERE gs.semester_id = gi.semester_id
                AND gs.group_id = gsc.group_id)'
    change_column :group_instructors, :group_semester_id, :integer, :null => false
    remove_column :group_instructors, :semester_id
  end
end
