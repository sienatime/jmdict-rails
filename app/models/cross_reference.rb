class CrossReference < ApplicationRecord
  belongs_to :sense
  belongs_to :cross_reference_sense, class_name: "Sense"
end
