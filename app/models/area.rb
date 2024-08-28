class Area < ApplicationRecord
  belongs_to :inspection
  has_many_attached :photos
  has_many :area_codes
  has_many :codes, through: :area_codes, class_name: 'Code'
  validates :floor, presence: true, numericality: { only_integer: true }
  validates :name, presence: true
  belongs_to :unit, optional: true

  has_paper_trail

  validates_uniqueness_of :name, scope: [:inspection_id, :floor]

  has_many :observations, dependent: :destroy

  def name
    if floor.present? && floor != 0
      ordinalized_floor = "#{ordinalize(floor)} floor"
      unless super.include?(ordinalized_floor)
        "#{ordinalized_floor} - #{super}"
      else
        super
      end
    else
      super
    end
  end

  private

  def ordinalize(number)
    if (11..13).include?(number % 100)
      "#{number}th"
    else
      case number % 10
      when 1 then "#{number}st"
      when 2 then "#{number}nd"
      when 3 then "#{number}rd"
      else "#{number}th"
      end
    end
  end
  
  

  attr_accessor :area_type

end
