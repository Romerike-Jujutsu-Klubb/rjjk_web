# frozen_string_literal: true

# rubocop: disable Rails/Output
class AddMd5ChecksumToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :md5_checksum, :string, limit: 32
    add_index :images, :md5_checksum, unique: true
    reversible do |dir|
      dir.up do
        i = 0
        Image.order(:id).each do |image|
          image.update_dimensions!
          image.update_md5_checksum!
        rescue ActiveRecord::RecordInvalid => e
          raise "Unknown error: #{e}" unless e.to_s == 'Det oppstod feil: Md5 checksum er allerede i bruk'

          print "\n#{i += 1}: Duplicate image: #{image.md5_checksum} #{image.id} #{image.name}"
          unless (original_image = Image.where.not(id: image.id).find_by(md5_checksum: image.md5_checksum))
            puts
            raise 'Could not find the original image!'
          end
          puts ", original_image: #{original_image.id} #{original_image.name}"
          raise 'Expected original id to be lower than our image' unless original_image.id < image.id

          if relations?(image)
            puts 'Merging into the original image:'

            image.application_steps.each do |as|
              puts "  as: #{as.position}: #{as.technique_application.name}, " \
                  "#{as.technique_application.rank.name}"
              as2 = ApplicationStep.find as.id
              as2.update! image_id: original_image.id
            end
            if image.member_image
              MemberImage.find(image.member_image.id).update!(image_id: original_image.id)
            end
            image.user_images.each do |ui|
              puts "  ui: #{ui.user.name} #{ui.rel_type}"
              ui.update! image_id: original_image.id
            end

            if relations?(image)
              raise "Cannot delete the image #{image.id} #{image.name} since it has relations."
            end
          end
          puts "Destroying the image #{image.id} #{image.name} "\
              "in favour of #{original_image.id} #{original_image.name}"
          image.destroy!
        end
      end
    end

    change_column_null :images, :md5_checksum, false
  end

  private

  def relations?(image)
    return unless image.application_steps.count > 0 || image.member_image || image.user_images.count > 0

    puts "image.application_steps: #{image.application_steps.count}"
    puts "image.member_image: #{image.member_image}"
    puts "image.user_images.count: #{image.user_images.count} "\
        "#{image.user_images.map { |ui| [ui.rel_type, ui.user.name] }}"
    true
  end
end
# rubocop: enable Rails/Output
