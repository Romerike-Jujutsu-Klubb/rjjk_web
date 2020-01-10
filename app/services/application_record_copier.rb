# frozen_string_literal: true

module ApplicationRecordCopier
  extend ActiveSupport::Concern

  class_methods do
    def copy_relations(*relations)
      @copy_relations = relations if relations.any?
      @copy_relations
    end
  end

  def copy
    copy = dup
    self.class.copy_relations&.each do |relation_name|
      relation = send(relation_name)
      copy_relation = copy.send(relation_name)
      relation.each { |record|
        copy_relation << record.copy
      }
    end
    copy
  end
end
