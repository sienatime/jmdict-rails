class Sense < ApplicationRecord
  belongs_to :entry
  # has_many :xrefs, class_name: "CrossReference", primary_key: :sense_id, foreign_key: :id

  def self.entry_for(sense_id)
    Sense.find(sense_id).entry.senses.first.glosses
  end

  def self.referenced_by(sense_id)
    CrossReference.where(cross_reference_sense_id: sense_id)
  end
end
